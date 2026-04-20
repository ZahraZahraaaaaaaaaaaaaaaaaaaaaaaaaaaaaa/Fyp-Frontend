/// Training hints aligned with Figma `ScenarioPlay.tsx` “Red Flags” panel (generic by scenario type).
List<String> redFlagsForScenarioType(String type) {
  switch (type) {
    case 'phishing':
    case 'invoice_scam':
      return const [
        'Unexpected sender domain or look‑alike spelling',
        'Urgency, threats, or “act within minutes” pressure',
        'Requests to click links or open attachments',
        'Requests for credentials, MFA codes, or sensitive data',
      ];
    case 'vishing':
      return const [
        'Unsolicited call claiming to be IT or support',
        'Pressure to read MFA/OTP codes aloud',
        'Requests for passwords or remote access',
        'Caller ID can be spoofed — verify via official callback',
      ];
    case 'baiting':
      return const [
        'Unknown USB/removable media is high risk',
        'Curiosity labels (e.g., “salaries”) are common lures',
        'Never plug untrusted media into corporate systems',
        'Hand media to security/IT for safe handling',
      ];
    case 'impersonation':
      return const [
        'Urgent money movement or gift‑card requests',
        'Executive tone without out‑of‑band verification',
        'Switching to personal channels to avoid oversight',
        'Verify via known contacts and official processes',
      ];
    default:
      return const [
        'Unexpected urgency or authority pressure',
        'Requests to bypass policy or controls',
        'Unfamiliar domains, links, or attachments',
        'Verify through trusted channels before acting',
      ];
  }
}
