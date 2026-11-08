"""GuardDuty response handler.

The default audit mode records the proposed containment without changing a workload.
Enforce mode stops only the EC2 instance explicitly identified by GuardDuty.
"""

import json
import logging
import os
from typing import Any

import boto3

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
THRESHOLD = 7.0


def instance_id_from(event: dict[str, Any]) -> str | None:
    """Return the GuardDuty EC2 instance identifier, if present."""
    return (
        event.get("detail", {})
        .get("resource", {})
        .get("instanceDetails", {})
        .get("instanceId")
    )


def decision(event: dict[str, Any], mode: str) -> dict[str, Any]:
    """Build a deterministic response decision without AWS side effects."""
    detail = event.get("detail", {})
    severity = float(detail.get("severity", 0))
    instance_id = instance_id_from(event)

    if severity < THRESHOLD:
        action, reason = "none", "below-severity-threshold"
    elif not instance_id:
        action, reason = "none", "no-ec2-instance-in-finding"
    elif mode == "enforce":
        action, reason = "stop-instance", "approved-containment-policy"
    else:
        action, reason = "would-stop-instance", "audit-mode"

    return {
        "action": action,
        "finding_id": detail.get("id"),
        "finding_type": detail.get("type", "unknown"),
        "instance_id": instance_id,
        "reason": reason,
        "severity": severity,
    }


def handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    """Evaluate a GuardDuty finding and optionally contain its EC2 instance."""
    mode = os.environ.get("RESPONSE_MODE", "audit").lower()
    if mode not in {"audit", "enforce"}:
        raise ValueError("RESPONSE_MODE must be audit or enforce")

    result = decision(event, mode)
    if result["action"] == "stop-instance":
        boto3.client("ec2").stop_instances(InstanceIds=[result["instance_id"]])

    LOGGER.info(json.dumps(result, sort_keys=True))
    return result
