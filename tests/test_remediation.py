"""Unit tests for side-effect-free GuardDuty response decisions."""

import importlib.util
import pathlib
import sys
import types
import unittest

ROOT = pathlib.Path(__file__).parents[1]
MODULE_PATH = ROOT / "modules" / "auto-remediation" / "lambda" / "index.py"
sys.modules.setdefault("boto3", types.SimpleNamespace(client=lambda _: None))
SPEC = importlib.util.spec_from_file_location("remediation", MODULE_PATH)
remediation = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(remediation)


def finding(severity=8, instance_id="i-0123456789abcdef0"):
    return {
        "detail": {
            "id": "finding-1",
            "type": "UnauthorizedAccess:EC2/SSHBruteForce",
            "severity": severity,
            "resource": {"instanceDetails": {"instanceId": instance_id}},
        }
    }


class DecisionTests(unittest.TestCase):
    def test_low_severity_is_not_actioned(self):
        self.assertEqual(remediation.decision(finding(6.9), "enforce")["action"], "none")

    def test_audit_mode_is_non_destructive(self):
        result = remediation.decision(finding(), "audit")
        self.assertEqual(result["action"], "would-stop-instance")

    def test_enforce_mode_contains_ec2(self):
        result = remediation.decision(finding(), "enforce")
        self.assertEqual(result["action"], "stop-instance")
        self.assertEqual(result["instance_id"], "i-0123456789abcdef0")

    def test_non_ec2_finding_is_not_actioned(self):
        event = finding()
        event["detail"]["resource"] = {"accessKeyDetails": {"accessKeyId": "redacted"}}
        result = remediation.decision(event, "enforce")
        self.assertEqual(result["reason"], "no-ec2-instance-in-finding")


if __name__ == "__main__":
    unittest.main()
