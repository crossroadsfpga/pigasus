classifications =
{
    {
        name = 'not-suspicious',
        text = 'Not Suspicious Traffic',
        priority = 3,
    },
    {
        name = 'unknown',
        text = 'Unknown Traffic',
        priority = 3,
    },
    {
        name = 'bad-unknown',
        text = 'Potentially Bad Traffic',
        priority = 2,
    },
    {
        name = 'attempted-recon',
        text = 'Attempted Information Leak',
        priority = 2,
    },
    {
        name = 'successful-recon-limited',
        text = 'Information Leak',
        priority = 2,
    },
    {
        name = 'successful-recon-largescale',
        text = 'Large Scale Information Leak',
        priority = 2,
    },
    {
        name = 'attempted-dos',
        text = 'Attempted Denial of Service',
        priority = 2,
    },
    {
        name = 'successful-dos',
        text = 'Denial of Service',
        priority = 2,
    },
    {
        name = 'attempted-user',
        text = 'Attempted User Privilege Gain',
        priority = 1,
    },
    {
        name = 'unsuccessful-user',
        text = 'Unsuccessful User Privilege Gain',
        priority = 1,
    },
    {
        name = 'successful-user',
        text = 'Successful User Privilege Gain',
        priority = 1,
    },
    {
        name = 'attempted-admin',
        text = 'Attempted Administrator Privilege Gain',
        priority = 1,
    },
    {
        name = 'successful-admin',
        text = 'Successful Administrator Privilege Gain',
        priority = 1,
    },
    {
        name = 'rpc-portmap-decode',
        text = 'Decode of an RPC Query',
        priority = 2,
    },
    {
        name = 'shellcode-detect',
        text = 'Executable Code was Detected',
        priority = 1,
    },
    {
        name = 'string-detect',
        text = 'A Suspicious String was Detected',
        priority = 3,
    },
    {
        name = 'suspicious-filename-detect',
        text = 'A Suspicious Filename was Detected',
        priority = 2,
    },
    {
        name = 'suspicious-login',
        text = 'An Attempted Login Using a Suspicious Username was Detected',
        priority = 2,
    },
    {
        name = 'system-call-detect',
        text = 'A System Call was Detected',
        priority = 2,
    },
    {
        name = 'tcp-connection',
        text = 'A TCP Connection was Detected',
        priority = 4,
    },
    {
        name = 'trojan-activity',
        text = 'A Network Trojan was Detected',
        priority = 1,
    },
    {
        name = 'unusual-client-port-connection',
        text = 'A Client was Using an Unusual Port',
        priority = 2,
    },
    {
        name = 'network-scan',
        text = 'Detection of a Network Scan',
        priority = 3,
    },
    {
        name = 'denial-of-service',
        text = 'Detection of a Denial of Service Attack',
        priority = 2,
    },
    {
        name = 'non-standard-protocol',
        text = 'Detection of a Non-Standard Protocol or Event',
        priority = 2,
    },
    {
        name = 'protocol-command-decode',
        text = 'Generic Protocol Command Decode',
        priority = 3,
    },
    {
        name = 'web-application-activity',
        text = 'Access to a Potentially Vulnerable Web Application',
        priority = 2,
    },
    {
        name = 'web-application-attack',
        text = 'Web Application Attack',
        priority = 1,
    },
    {
        name = 'misc-activity',
        text = 'Misc activity',
        priority = 3,
    },
    {
        name = 'misc-attack',
        text = 'Misc Attack',
        priority = 2,
    },
    {
        name = 'icmp-event',
        text = 'Generic ICMP event',
        priority = 3,
    },
    {
        name = 'inappropriate-content',
        text = 'Inappropriate Content was Detected',
        priority = 1,
    },
    {
        name = 'policy-violation',
        text = 'Potential Corporate Privacy Violation',
        priority = 1,
    },
    {
        name = 'default-login-attempt',
        text = 'Attempt to Login By a Default Username and Password',
        priority = 2,
    },
    {
        name = 'sdf',
        text = 'Sensitive Data was Transmitted Across the Network',
        priority = 2,
    },
    {
        name = 'file-format',
        text = 'Known malicious file or file based exploit',
        priority = 1,
    },
    {
        name = 'malware-cnc',
        text = 'Known malware command and control traffic',
        priority = 1,
    },
    {
        name = 'client-side-exploit',
        text = 'Known client side exploit attempt',
        priority = 1,
    },
}

--[[    COMMENTS:
 These lines were commented in the configuration file:


    $Id: classification.config,v 1.1000.2.59 2017-03-29 23:30:35 vrtbuild Exp $
    The following includes information for prioritizing rules


    Each classification includes a shortname, a description, and a default
    priority for that classification.


    This allows alerts to be classified and prioritized. You can specify
    what priority each classification has. Any rule can override the default
    priority for that rule.


    Here are a few example rules:


    alert TCP any any -> any 80 (msg: "EXPLOIT ntpdx overflow";
    dsize: > 128; classtype:attempted-admin; priority:10;


    alert TCP any any -> any 25 (msg:"SMTP expn root"; flags:A+; \
    content:"expn root"; nocase; classtype:attempted-recon;)


    The first rule will set its type to "attempted-admin" and override
    the default priority for that type to 10.


    The second rule set its type to "attempted-recon" and set its
    priority to the default for that type.


    config classification:shortname,short description,priority


    NEW CLASSIFICATIONS
--]]

