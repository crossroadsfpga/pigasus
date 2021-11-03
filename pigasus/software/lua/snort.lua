---------------------------------------------------------------------------
-- Snort++ prototype configuration
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- setup environment
---------------------------------------------------------------------------
-- given:
-- export DIR=/install/path
-- configure --prefix=$DIR
-- make install
--
-- then:
-- export LUA_PATH=$DIR/include/snort/lua/?.lua\;\;
-- export SNORT_LUA_PATH=$DIR/conf/
---------------------------------------------------------------------------



require("snort_config")

dir = os.getenv('SNORT_LUA_PATH')

if ( not dir ) then
    dir = '.'
end

dofile(dir .. '/snort_defaults.lua')


HOME_NET = 'any'

EXTERNAL_NET = 'any'

DNS_SERVERS = HOME_NET

SMTP_SERVERS = HOME_NET

HTTP_SERVERS = HOME_NET

SQL_SERVERS = HOME_NET

TELNET_SERVERS = HOME_NET

SSH_SERVERS = HOME_NET

FTP_SERVERS = HOME_NET

SIP_SERVERS = HOME_NET

HTTP_PORTS = [[ 36 80 81 82 83 84 85 86 87 88 89 90 311 383 555 591 593 631
    801 808 818 901 972 1158 1220 1414 1533 1741 1812 1830 1942 2231 2301
    2381 2578 2809 2980 3029 3037 3057 3128 3443 3702 4000 4343 4848 5000
    5117 5250 5450 5600 5814 6080 6173 6988 7000 7001 7005 7071 7144 7145
    7510 7770 7777 7778 7779 8000 8001 8008 8014 8015 8020 8028 8040 8080
    8081 8082 8085 8088 8090 8118 8123 8180 8181 8182 8222 8243 8280 8300
    8333 8344 8400 8443 8500 8509 8787 8800 8888 8899 8983 9000 9002 9060
    9080 9090 9091 9111 9290 9443 9447 9710 9788 9999 10000 11371 12601 13014
    15489 19980 29991 33300 34412 34443 34444 40007 41080 44449 50000 50002
    51423 53331 55252 55555 56712 ]]

SHELLCODE_PORTS = '!80'

ORACLE_PORTS = '1024:'

SSH_PORTS = '22'

FTP_PORTS = '21 2100 3535'

SIP_PORTS = '5060 5061 5600'

FILE_DATA_PORTS = HTTP_PORTS .. ' 110 143'

GTP_PORTS = '2123 2152 3386'

AIM_SERVERS = [[ 64.12.24.0/23 64.12.28.0/23 64.12.161.0/24 64.12.163.0/24
    64.12.200.0/24 205.188.3.0/24 205.188.5.0/24 205.188.7.0/24
    205.188.9.0/24 205.188.153.0/24 205.188.179.0/24 205.188.248.0/24 ]]

RULE_PATH = '../rules'

SO_RULE_PATH = '../so_rules'

PREPROC_RULE_PATH = '../preproc_rules'

WHITE_LIST_PATH = '../rules'

BLACK_LIST_PATH = '../rules'

include 'classification.config.lua'

include 'reference.config.lua'

-- Add rules here. We only provide a sample rule here. 
-- To get Snort Registered Rules, please purchase it from snort.org
local_rules = 
[[
include ../rules/sample.rules
]]

deleted_snort_config_options =
{
    --option deleted: 'config disable_decode_alerts[:.*]'
    --option deleted: 'config disable_ipopt_alerts[:.*]'
    --option deleted: 'config disable_tcpopt_alerts[:.*]'
    --option deleted: 'config disable_tcpopt_experimental_alerts[:.*]'
    --option deleted: 'config disable_tcpopt_obsolete_alerts[:.*]'
    --option deleted: 'config disable_tcpopt_ttcp_alerts[:.*]'
}

search_engine =
{
    split_any_any = true,
    search_method = 'hyperscan',
    search_optimize = true,
    max_pattern_len = 20,
    debug = true,
    debug_print_nocontent_rule_tests = true,
    debug_print_rule_group_build_details = true,
    show_fast_patterns = true,
    --detect_raw_tcp = true,
    --enable_single_rule_group = true,
    --This table was previously 'config detection: ...
    --option change: 'ac-split' --> 'ac_full'
    --option change: 'ac-split' --> 'split_any_any'
    --option change: 'max-pattern-len' --> 'max_pattern_len'
    --option change: 'search-method' --> 'search_method'
    --option change: 'search-optimize' --> 'search_optimize'
}

event_queue =
{
    max_queue = 8,
    log = 5,
    order_events = 'content_length',
}

profiler =
{
    rules =
    {
        show = true,
        sort = 'total_time',
        --option change: 'print' --> 'count'
        --option change: 'sort avg_ticks' --> 'sort = avg_check'
    },
    modules =
    {
        show = true,
        sort = 'total_time',
        --option change: 'print' --> 'count'
        --option change: 'sort avg_ticks' --> 'sort = avg_check'
    },

    memory =
    {
        show = false,
    }
}

process =
{
    --plugin_path = '/usr/local/lib/snort_dynamicpreprocessor/',
    --Cannot add specific files to Snort++ plugin path.  Use 'plugin_path =
    --    <dir>' instead of adding specific file:
    --    /usr/local/lib/snort_dynamicengine/libsf_engine.so
    --Since paths have changed between Snort and  Snort++, commenting out any
    --    plugin paths.  You must manually add them
    --option change: 'dynamicengine' --> 'plugin_path'
    --option change: 'dynamicpreprocessor' --> 'plugin_path'
}

stream_ip =
{
    max_frags = 65536,
    policy = 'windows',
    max_overlaps = 10,
    min_frag_length = 100,
    session_timeout = 180,
    --option change: 'min_fragment_length' --> 'min_frag_length'
    --option change: 'overlap_limit' --> 'max_overlaps'
    --option change: 'timeout' --> 'session_timeout'
    --option deleted: 'detect_anomalies'
}

stream =
{
    tcp_cache =
    {
        max_sessions = 262144,
        --option change: 'max_tcp' --> 'max_sessions'
    },
    udp_cache =
    {
        max_sessions = 131072,
        --option change: 'max_udp' --> 'max_sessions'
    },
    --option deleted: 'track_icmp'
    --option deleted: 'track_tcp'
    --option deleted: 'track_udp'
}

active =
{
    max_responses = 2,
    min_interval = 5,
    --option change: 'max_active_responses' --> 'max_responses'
    --option change: 'min_response_seconds' --> 'min_interval'
}

reject =
{
    reset = 'both',
}

stream_udp =
{
    session_timeout = 180,
    --option change: 'timeout' --> 'session_timeout'
}

http_inspect =
{
    iis_unicode_map_file = 'unicode.map',
    iis_unicode_code_page = 1252,
    --http_methods = 'GET POST PUT SEARCH MKCOL COPY MOVE LOCK UNLOCK NOTIFY POLL BCOPY BDELETE BMOVE LINK UNLINK OPTIONS HEAD DELETE TRACE TRACK CONNECT SOURCE SUBSCRIBE UNSUBSCRIBE PROPFIND PROPPATCH BPROPFIND BPROPPATCH RPC_CONNECT PROXY_SUCCESS BITS_POST CCM_POST SMS_POST RPC_IN_DATA RPC_OUT_DATA RPC_ECHO_DATA',
    response_depth = -1,
    request_depth = -1,
    oversize_dir_length = 500,
    --unzip = true,
    unzip = false,
    normalize_utf = true,
    normalize_javascript = false,
    utf8_bare_byte = false,
    iis_double_decode = false,
    backslash_to_slash = false,
    iis_unicode = false,
    utf8 = false,
    percent_u = true,
    --decompress_swf = 'deflate lzma',
    decompress_swf = true,
    --decompress_pdf = 'deflate',
    decompress_pdf = true,
    simplify_path = false,
    bad_characters = '0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7',
    --option change: 'bare_byte' --> 'utf8_bare_byte'
    --option change: 'client_flow_depth' --> 'request_depth'
    --option change: 'directory' --> 'simplify_path'
    --option change: 'double_decode' --> 'iis_double_decode'
    --option change: 'http_inspect_server' --> 'http_inspect'
    --option change: 'iis_backslash' --> 'backslash_to_slash'
    --option change: 'inspect_gzip' --> 'unzip'
    --option change: 'multi_slash' --> 'simplify_path'
    --option change: 'non_rfc_char' --> 'bad_characters'
    --option change: 'ports' --> 'bindings'
    --option change: 'server_flow_depth' --> 'response_depth'
    --option change: 'u_encode' --> 'percent_u'
    --option change: 'utf_8' --> 'utf8'
    --option deleted: 'apache_whitespace'
    --option deleted: 'ascii'
    --option deleted: 'chunk_length'
    --option deleted: 'compress_depth'
    --option deleted: 'decompress_depth'
    --option deleted: 'enable_cookie'
    --option deleted: 'extended_response_inspection'
    --option deleted: 'iis_delimiter'
    --option deleted: 'max_header_length'
    --option deleted: 'max_headers'
    --option deleted: 'max_spaces'
    --option deleted: 'post_depth'
    --option deleted: 'small_chunk_length'
    --option deleted: 'unlimited_decompress'
    --option deleted: 'webroot'
}

rpc_decode =
{
    --option deleted: 'no_alert_incomplete'
    --option deleted: 'no_alert_large_fragments'
    --option deleted: 'no_alert_multiple_requests'
}

bo =
{
}

telnet =
{
    encrypted_traffic = false,
    check_encrypted = true,
    ayt_attack_thresh = 20,
    normalize = true,
    --check bindings table for port information
    --option change: 'ports' --> 'bindings'
    --option deleted: 'detect_anomalies'
    --option deleted: 'inspection_type'
}

ftp_server =
{
    encrypted_traffic = false,
    check_encrypted = true,
    def_max_param_len = 100,
    telnet_cmds = true,
    ignore_telnet_erase_cmds = true,
    chk_str_fmt = ftp_format_commands,
    data_chan_cmds = ftp_default_data_chan_cmds,
    data_xfer_cmds = ftp_default_data_xfer_cmds,
    encr_cmds = ftp_default_encr_cmds,
    file_get_cmds = ftp_default_file_get_cmds,
    file_put_cmds = ftp_default_file_put_cmds,
    ftp_cmds = ftp_default_cmds,
    login_cmds = ftp_default_login_cmds,
    cmd_validity = ftp_command_specs,
    --check bindings table for port information
    --option change: 'ports' --> 'bindings'
    --option deleted: 'inspection_type'
}

ftp_data =
{
}

ftp_client =
{
    max_resp_len = 256,
    bounce = true,
    ignore_telnet_erase_cmds = true,
    telnet_cmds = true,
}

smtp =
{
    b64_decode_depth = -1,
    qp_decode_depth = -1,
    bitenc_decode_depth = -1,
    uu_decode_depth = -1,
    log_mailfrom = true,
    log_rcptto = true,
    log_filename = true,
    log_email_hdrs = true,
    normalize = 'cmds',
    max_command_line_len = 512,
    max_header_line_len = 1000,
    max_response_line_len = 512,
    xlink2state = 'alert',
    normalize_cmds = [[ ATRN AUTH BDAT CHUNKING DATA DEBUG EHLO EMAL ESAM
        ESND ESOM ETRN EVFY EXPN HELO HELP IDENT MAIL NOOP ONEX QUEU QUIT
        RCPT RSET SAML SEND SOML STARTTLS TICK TIME TURN TURNME VERB VRFY
        X-ADAT X-DRCP X-ERCP X-EXCH50 X-EXPS X-LINK2STATE XADR XAUTH XCIR
        XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR ]],
    valid_cmds = [[ ATRN AUTH BDAT CHUNKING DATA DEBUG EHLO EMAL ESAM ESND
        ESOM ETRN EVFY EXPN HELO HELP IDENT MAIL NOOP ONEX QUEU QUIT RCPT
        RSET SAML SEND SOML STARTTLS TICK TIME TURN TURNME VERB VRFY X-ADAT
        X-DRCP X-ERCP X-EXCH50 X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50
        XGEN XLICENSE XQUE XSTA XTRN XUSR ]],
    alt_max_command_line_len =
    {
        {
            command = 'MAIL',
            length = 260,
        },
        {
            command = 'RCPT',
            length = 300,
        },
        {
            command = 'HELP',
            length = 500,
        },
        {
            command = 'HELO',
            length = 500,
        },
        {
            command = 'ETRN',
            length = 500,
        },
        {
            command = 'EHLO',
            length = 500,
        },
        {
            command = 'EXPN',
            length = 255,
        },
        {
            command = 'VRFY',
            length = 255,
        },
        {
            command = 'ATRN',
            length = 255,
        },
        {
            command = 'SIZE',
            length = 255,
        },
        {
            command = 'BDAT',
            length = 255,
        },
        {
            command = 'DEBUG',
            length = 255,
        },
        {
            command = 'EMAL',
            length = 255,
        },
        {
            command = 'ESAM',
            length = 255,
        },
        {
            command = 'ESND',
            length = 255,
        },
        {
            command = 'ESOM',
            length = 255,
        },
        {
            command = 'EVFY',
            length = 255,
        },
        {
            command = 'IDENT',
            length = 255,
        },
        {
            command = 'NOOP',
            length = 255,
        },
        {
            command = 'RSET',
            length = 255,
        },
        {
            command = 'SEND',
            length = 246,
        },
        {
            command = 'SAML',
            length = 246,
        },
        {
            command = 'SOML',
            length = 246,
        },
        {
            command = 'AUTH',
            length = 246,
        },
        {
            command = 'TURN',
            length = 246,
        },
        {
            command = 'DATA',
            length = 246,
        },
        {
            command = 'QUIT',
            length = 246,
        },
        {
            command = 'ONEX',
            length = 246,
        },
        {
            command = 'QUEU',
            length = 246,
        },
        {
            command = 'STARTTLS',
            length = 246,
        },
        {
            command = 'TICK',
            length = 246,
        },
        {
            command = 'TIME',
            length = 246,
        },
        {
            command = 'TURNME',
            length = 246,
        },
        {
            command = 'VERB',
            length = 246,
        },
        {
            command = 'X-EXPS',
            length = 246,
        },
        {
            command = 'X-LINK2STATE',
            length = 246,
        },
        {
            command = 'XADR',
            length = 246,
        },
        {
            command = 'XAUTH',
            length = 246,
        },
        {
            command = 'XCIR',
            length = 246,
        },
        {
            command = 'XEXCH50',
            length = 246,
        },
        {
            command = 'XGEN',
            length = 246,
        },
        {
            command = 'XLICENSE',
            length = 246,
        },
        {
            command = 'XQUE',
            length = 246,
        },
        {
            command = 'XSTA',
            length = 246,
        },
        {
            command = 'XTRN',
            length = 246,
        },
        {
            command = 'XUSR',
            length = 246,
        },
    },
    --option change: 'ports' --> 'bindings'
    --option deleted: 'inspection_type'
}

ssh =
{
    max_client_bytes = 19600,
    max_encrypted_packets = 20,
    max_server_version_len = 100,
    --option change: 'server_ports' --> 'bindings'
    --option deleted: 'autodetect'
    --option deleted: 'enable_protomismatch'
    --option deleted: 'enable_respoverflow'
    --option deleted: 'enable_srvoverflow'
    --option deleted: 'enable_ssh1crc32'
}

dce_smb =
{
    policy = 'WinXP',
    smb_max_chain = 3,
    smb_invalid_shares = 'C$ D$ ADMIN$',
    --option deleted: 'events'
    --option deleted: 'memcap'
}

dce_tcp =
{
    policy = 'WinXP',
    --option deleted: 'autodetect'
    --option deleted: 'events'
    --option deleted: 'memcap'
}

dce_udp =
{
    --option deleted: 'autodetect'
    --option deleted: 'events'
    --option deleted: 'memcap'
}

dce_http_proxy =
{
    --option deleted: 'events'
    --option deleted: 'memcap'
}

dce_http_server =
{
    --option deleted: 'autodetect'
    --option deleted: 'events'
    --option deleted: 'memcap'
}

dns =
{
    --option change: 'ports' --> 'bindings'
    --option deleted: 'enable_rdata_overflow'
}

ssl =
{
    trust_servers = true,
    --option change: 'ports' --> 'bindings'
    --option deleted: 'noinspect_encrypted'
}

sip =
{
    max_uri_len = 512,
    max_call_id_len = 80,
    max_requestName_len = 20,
    max_from_len = 256,
    max_to_len = 256,
    max_via_len = 1024,
    max_contact_len = 512,
    max_content_len = 2048,
    methods = [[ invite cancel ack bye register options refer subscribe
        update join info message notify benotify do qauth sprack publish
        service unsubscribe prack ]],
    --option change: 'ports' --> 'bindings'
    --option deleted: 'max_sessions'
}

imap =
{
    b64_decode_depth = -1,
    qp_decode_depth = -1,
    bitenc_decode_depth = -1,
    uu_decode_depth = -1,
    --option change: 'ports' --> 'bindings'
}

pop =
{
    b64_decode_depth = -1,
    qp_decode_depth = -1,
    bitenc_decode_depth = -1,
    uu_decode_depth = -1,
    --option change: 'ports' --> 'bindings'
}

modbus =
{
    --option change: 'ports' --> 'bindings'
}

dnp3 =
{
    check_crc = true,
    --option change: 'ports' --> 'bindings'
    --option deleted: 'memcap'
}

network =
{
    checksum_eval = 'none',
    --option change: 'checksum_mode' --> 'checksum_eval'
}

detection =
{
    pcre_match_limit = 1500,
    pcre_match_limit_recursion = 1500,
    trace = 0x20 + 0x10 + 0x2 +0x4,
}

stream_tcp =
{
    max_pdu = 16000,
    policy = 'windows',
    require_3whs = 180,
    overlap_limit = 10,
    session_timeout = 180,
    small_segments =
    {
        count = 3,
        maximum_size = 150,
    },
    --Zhipeng Add for debug
    show_rebuilt_packets = false,
    --reassemble_async = true,
    --option change: 'both ports' --> 'binder.when.ports; binder.when.role =
    --    any'
    --option change: 'client ports' --> 'binder.when.ports; binder.when.role =
    --    client'
    --option change: 'paf_max [0:63780]' --> 'max_pdu [1460:32768]'
    --option change: 'timeout' --> 'session_timeout'
    --option deleted: 'detect_anomalies'
}

normalizer =
{
    ip6 = true,
    ip4 =
    {
    },
    tcp =
    {
        block = true,
        rsv = true,
        pad = true,
        urp = true,
        req_urg = true,
        req_pay = true,
        req_urp = true,
        ips = true,
        ecn = 'stream',
    },
    --option change: 'preprocessor normalize_ip6' --> 'ip6 = <bool>'
}

binder =
{
    { when = { service = 'dce_tcp', proto = 'tcp', ports = '135 593', }, use = { type = 'dce_tcp', }, },
    { when = { service = 'cvs', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'dcerpc', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'dns', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'ftp', proto = 'tcp', }, use = { type = 'ftp_client', }, },
    { when = { service = 'ftp', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'http', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'imap', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'login', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'mssql', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'mysql', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'nameserver', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'netbios-ssn', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'oracle', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'pop3', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'shell', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'smtp', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'sunrpc', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'telnet', proto = 'tcp', }, use = { type = 'stream_tcp', }, },
    { when = { service = 'ftp-data', }, use = { type = 'ftp_data', }, },
    { when = { proto = 'tcp', role = 'client', ports = '21 22 23 25 42 53 70 79 109 110 111 113 119 135 136 137 139 143 161 445 513 514 587 593 691 1433 1521 1741 2100 3306 6070 6665 6666 6667 6668 6669 7000 8181 32770 32771 32772 32773 32774 32775 32776 32777 32778 32779', }, use = { type = 'stream_tcp', }, },
    { when = { proto = 'tcp', ports = '20000', }, use = { type = 'dnp3', }, },
    { when = { proto = 'tcp', ports = '502', }, use = { type = 'modbus', }, },
    { when = { proto = 'tcp', ports = '110', }, use = { type = 'pop', }, },
    { when = { proto = 'tcp', ports = '143', }, use = { type = 'imap', }, },
    { when = { proto = 'tcp', ports = '53', }, use = { type = 'dns', }, },
    { when = { proto = 'tcp', ports = '593', }, use = { type = 'dce_http_server', }, },
    { when = { proto = 'tcp', ports = '22', }, use = { type = 'ssh', }, },
    { when = { proto = 'tcp', ports = '23', }, use = { type = 'telnet', }, },
    { when = { proto = 'udp', ports = '20000', }, use = { type = 'dnp3', }, },
    { when = { proto = 'udp', ports = '135', }, use = { type = 'dce_udp', }, },
    { when = { proto = 'tcp', ports = '139 445', }, use = { type = 'dce_smb', }, },
    { when = { proto = 'tcp', ports = '21 2100 3535', }, use = { type = 'ftp_server', }, },
    { when = { proto = 'tcp', ports = '25 465 587 691 465 587 691', }, use = { type = 'smtp', }, },
    { when = { proto = 'tcp', ports = '111 32770 32771 32772 32773 32774 32775 32776 32777 32778 32779', }, use = { type = 'rpc_decode', }, },
    { when = { proto = 'tcp', ports = '443 465 563 636 989 992 993 994 995 5061 7801 7802 7900 7901 7902 7903 7904 7905 7906 7907 7908 7909 7910 7911 7912 7913 7914 7915 7916 7917 7918 7919 7920', }, use = { type = 'ssl', }, },
    { when = { proto = 'tcp', ports = '36 80 81 82 83 84 85 86 87 88 89 90 311 383 555 591 593 631 801 808 818 901 972 1158 1220 1414 1533 1741 1812 1830 1942 2231 2301 2381 2578 2809 2980 3029 3037 3057 3128 3443 3702 4000 4343 4848 5000 5117 5250 5450 5600 5814 6080 6173 6988 7000 7001 7005 7071 7144 7145 7510 7770 7777 7778 7779 8000 8001 8008 8014 8015 8020 8028 8040 8080 8081 8082 8085 8088 8090 8118 8123 8180 8181 8182 8222 8243 8280 8300 8333 8344 8400 8443 8500 8509 8787 8800 8888 8899 8983 9000 9002 9060 9080 9090 9091 9111 9290 9443 9447 9710 9788 9999 10000 11371 12601 13014 15489 19980 29991 33300 34412 34443 34444 40007 41080 44449 50000 50002 51423 53331 55252 55555 56712', }, use = { type = 'http_inspect', }, },
    { when = { proto = 'tcp', ports = '36 80 81 82 83 84 85 86 87 88 89 90 110 311 383 443 465 563 555 591 593 631 636 801 808 818 901 972 989 992 993 994 995 1158 1220 1414 1533 1741 1812 1830 1942 2231 2301 2381 2578 2809 2980 3000 3001 3029 3037 3057 3128 3300 3443 3702 3901 4000 4343 4848 5000 5117 5250 5450 5555 5600 5814 6080 6173 6988 7907 7000 7001 7005 7071 7144 7145 7510 7802 7770 7777 7778 7779 7801 7900 7901 7902 7903 7904 7905 7906 7908 7909 7910 7911 7912 7913 7914 7915 7916 7917 7918 7919 7920 8000 8001 8008 8014 8015 8020 8028 8040 8080 8081 8082 8085 8088 8090 8118 8123 8180 8181 8182 8222 8243 8280 8300 8333 8344 8400 8443 8500 8509 8787 8800 8888 8899 8983 9000 9002 9060 9080 9090 9091 9111 9290 9443 9447 9710 9788 9999 10000 11371 12601 13014 15489 19980 29991 33300 34412 34443 34444 40007 41080 44449 50000 50002 51423 53331 55252 55555 56712', }, use = { type = 'stream_tcp', }, },
    { when = { ports = '5060 5061 5600', }, use = { type = 'sip', }, },
}

ips =
{
    rules = local_rules,
}

--[[    COMMENTS:
 These lines were commented in the configuration file:


    --------------------------------------------------
    VRT Rule Packages Snort.conf


    For more information visit us at:
    http://www.snort.org Snort Website
    http://vrt-blog.snort.org/ Sourcefire VRT Blog


    Mailing list Contact: snort-sigs@lists.sourceforge.net
    False Positive reports: fp@sourcefire.com
    Snort bugs: bugs@snort.org


    Compatible with Snort Versions:
    VERSIONS : 2.9.14.1


    Snort build options:
    OPTIONS : --enable-gre --enable-mpls --enable-targetbased --enable-ppm
        --enable-perfprofiling --enable-zlib --enable-active-response
        --enable-normalizer --enable-reload --enable-react --enable-flexresp3


    Additional information:
    This configuration file enables active response, to run snort in
    test mode -T you are required to supply an interface -i <interface>
    or test mode will fail to fully validate the configuration and
    exit with a FATAL error
    --------------------------------------------------
    ##################################################
    This file contains a sample snort configuration.
    You should take the following steps to create your own custom
        configuration:


    1) Set the network variables.
    2) Configure the decoder
    3) Configure the base detection engine
    4) Configure dynamic loaded libraries
    5) Configure preprocessors
    6) Configure output plugins
    7) Customize your rule set
    8) Customize preprocessor and decoder rule set
    9) Customize shared object rule set
    ##################################################
    ##################################################
    Step #1: Set the network variables. For more information, see
        README.variables
    ##################################################
    Setup the network addresses you are protecting
    Set up the external network addresses. Leave as "any" in most situations
    List of DNS servers on your network
    List of SMTP servers on your network
    List of web servers on your network
    List of sql servers on your network
    List of telnet servers on your network
    List of ssh servers on your network
    List of ftp servers on your network
    List of sip servers on your network
    List of ports you run web servers on
    List of ports you want to look for SHELLCODE on.
    List of ports you might see oracle attacks on
    List of ports you want to look for SSH connections on:
    List of ports you run ftp servers on
    List of ports you run SIP servers on
    List of file data ports for file inspection
    List of GTP ports for GTP preprocessor
    other variables, these should not be modified
    Path to your rules files (this can be a relative path)
    Note for Windows users: You are advised to make this an absolute path,
    such as: c:\snort\rules
    If you are using reputation preprocessor set these
    ##################################################
    Step #2: Configure the decoder. For more information, see README.decode
    ##################################################
    Stop generic decode events:
    Stop Alerts on experimental TCP options
    Stop Alerts on obsolete TCP options
    Stop Alerts on T/TCP alerts
    Stop Alerts on all other TCPOption type events:
    Stop Alerts on invalid ip options
    Alert if value in length field (IP, TCP, UDP) is greater th elength of the
        packet
    config enable_decode_oversized_alerts
    Same as above, but drop packet if in Inline mode (requires
        enable_decode_oversized_alerts)
    config enable_decode_oversized_drops
    Configure IP / TCP checksum mode
    Configure maximum number of flowbit references. For more information, see
        README.flowbits
    config flowbits_size: 64
    Configure ports to ignore
    config ignore_ports: tcp 21 6667:6671 1356
    config ignore_ports: udp 1:17 53
    Configure active response for non inline operation. For more information,
        see REAMDE.active
    config response: eth0 attempts 2
    Configure DAQ related options for inline operation. For more information,
        see README.daq


    config daq: <type>
    config daq_dir: <dir>
    config daq_mode: <mode>
    config daq_var: <var>


    <type> ::= pcap | afpacket | dump | nfq | ipq | ipfw
    <mode> ::= read-file | passive | inline
    <var> ::= arbitrary <name>=<value passed to DAQ
    <dir> ::= path as to where to look for DAQ module so's
    Configure specific UID and GID to run snort as after dropping privs. For
        more information see snort -h command line options


    config set_gid:
    config set_uid:
    Configure default snaplen. Snort defaults to MTU of in use interface. For
        more information see README


    config snaplen:


    Configure default bpf_file to use for filtering what traffic reaches snort.
        For more information see snort -h command line options (-F)


    config bpf_file:


    Configure default log directory for snort to log to. For more information
        see snort -h command line options (-l)


    config logdir:
    ##################################################
    Step #3: Configure the base detection engine. For more information, see
        README.decode
    ##################################################
    Configure PCRE match limitations
    Configure the detection engine See the Snort Manual, Configuring Snort -
        Includes - Config
    Configure the event queue. For more information, see README.event_queue
    ##################################################
    # Configure GTP if it is to be used.
    # For more information, see README.GTP
    ###################################################
    config enable_gtp
    ##################################################
    Per packet and rule latency enforcement
    For more information see README.ppm
    ##################################################
    Per Packet latency configuration
    config ppm: max-pkt-time 250, \
    fastpath-expensive-packets, \
    pkt-log
    Per Rule latency configuration
    config ppm: max-rule-time 200, \
    threshold 3, \
    suspend-expensive-rules, \
    suspend-timeout 20, \
    rule-log alert
    ##################################################
    Configure Perf Profiling for debugging
    For more information see README.PerfProfiling
    ##################################################
    ##################################################
    Configure protocol aware flushing
    For more information see README.stream5
    ##################################################
    ##################################################
    Step #4: Configure dynamic loaded libraries.
    For more information, see Snort Manual, Configuring Snort - Dynamic Modules
    ##################################################
    path to dynamic preprocessor libraries
    path to base preprocessor engine
    path to dynamic rules libraries (Shared Object (SO) Rules)
    Set this path to where the compiled *.so binaries are installed
    dynamicdetection directory /usr/local/lib/snort_dynamicrules
    ##################################################
    Step #5: Configure preprocessors
    For more information, see the Snort Manual, Configuring Snort -
        Preprocessors
    ##################################################
    GTP Control Channle Preprocessor. For more information, see README.GTP
    preprocessor gtp: ports { 2123 3386 2152 }
    Inline packet normalization. For more information, see README.normalize
    Does nothing in IDS mode
    preprocessor normalize_icmp4
    preprocessor normalize_icmp6
    Target-based IP defragmentation. For more inforation, see README.frag3
    Target-Based stateful inspection/stream reassembly. For more inforation,
        see README.stream5
    performance statistics. For more information, see the Snort Manual,
        Configuring Snort - Preprocessors - Performance Monitor
    preprocessor perfmonitor: time 300 file /var/snort/snort.stats pktcnt 10000
    HTTP normalization and anomaly detection. For more information, see
        README.http_inspect
    ONC-RPC normalization and anomaly detection. For more information, see the
        Snort Manual, Configuring Snort - Preprocessors - RPC Decode
    Back Orifice detection.
    FTP / Telnet normalization and anomaly detection. For more information, see
        README.ftptelnet
    SMTP normalization and anomaly detection. For more information, see
        README.SMTP
    Portscan detection. For more information, see README.sfportscan
    preprocessor sfportscan: proto { all } memcap { 10000000 } sense_level {
        low }
    ARP spoof detection. For more information, see the Snort Manual -
        Configuring Snort - Preprocessors - ARP Spoof Preprocessor
    preprocessor arpspoof
    preprocessor arpspoof_detect_host: 192.168.40.1 f0:0f:00:f0:0f:00
    SSH anomaly detection. For more information, see README.ssh
    SMB / DCE-RPC normalization and anomaly detection. For more information,
        see README.dcerpc2
    DNS anomaly detection. For more information, see README.dns
    SSL anomaly detection and traffic bypass. For more information, see
        README.ssl
    SDF sensitive data preprocessor. For more information see
        README.sensitive_data
    SIP Session Initiation Protocol preprocessor. For more information see
        README.sip
    IMAP preprocessor. For more information see README.imap
    POP preprocessor. For more information see README.pop
    Modbus preprocessor. For more information see README.modbus
    DNP3 preprocessor. For more information see README.dnp3
    Reputation preprocessor. For more information see README.reputation
    preprocessor reputation: \
    memcap 500, \
    priority whitelist, \
    nested_ip inner, \
    whitelist $WHITE_LIST_PATH/white_list.rules, \
    blacklist $BLACK_LIST_PATH/black_list.rules
    ##################################################
    Step #6: Configure output plugins
    For more information, see Snort Manual, Configuring Snort - Output Modules
    ##################################################
    unified2
    Recommended for most installs
    output unified2: filename merged.log, limit 128, nostamp, mpls_event_types,
        vlan_event_types
    Additional configuration for specific types of installs
    output alert_unified2: filename snort.alert, limit 128, nostamp
    output log_unified2: filename snort.log, limit 128, nostamp
    syslog
    output alert_syslog: LOG_AUTH LOG_ALERT
    pcap
    output log_tcpdump: tcpdump.log
    metadata reference data. do not modify these lines
    ##################################################
    Step #7: Customize your rule set
    For more information, see Snort Manual, Writing Snort Rules


    NOTE: All categories are enabled in this conf file
    ##################################################
    site specific rules
    ##################################################
    Step #8: Customize your preprocessor and decoder alerts
    For more information, see README.decoder_preproc_rules
    ##################################################
    decoder and preprocessor event rules
    include $PREPROC_RULE_PATH/preprocessor.rules
    include $PREPROC_RULE_PATH/decoder.rules
    include $PREPROC_RULE_PATH/sensitive-data.rules
    ##################################################
    Step #9: Customize your Shared Object Snort Rules
    For more information, see
        http://vrt-blog.snort.org/2009/01/using-vrt-certified-shared-object-rules.html
    ##################################################
    dynamic library rules (Shared Object (SO) Rules)
    These includes point to the SO stub rules files. For the detections to
        work, you
    must also point "dynamicdetection directory" option above to point to where
        the
    compiled SO Rule *.so binaries are located
    include $SO_RULE_PATH/browser-chrome.rules
    include $SO_RULE_PATH/browser-ie.rules
    include $SO_RULE_PATH/browser-other.rules
    include $SO_RULE_PATH/exploit-kit.rules
    include $SO_RULE_PATH/file-executable.rules
    include $SO_RULE_PATH/file-flash.rules
    include $SO_RULE_PATH/file-image.rules
    include $SO_RULE_PATH/file-java.rules
    include $SO_RULE_PATH/file-multimedia.rules
    include $SO_RULE_PATH/file-office.rules
    include $SO_RULE_PATH/file-other.rules
    include $SO_RULE_PATH/file-pdf.rules
    include $SO_RULE_PATH/indicator-shellcode.rules
    include $SO_RULE_PATH/malware-cnc.rules
    include $SO_RULE_PATH/malware-other.rules
    include $SO_RULE_PATH/netbios.rules
    include $SO_RULE_PATH/os-linux.rules
    include $SO_RULE_PATH/os-other.rules
    include $SO_RULE_PATH/os-windows.rules
    include $SO_RULE_PATH/policy-other.rules
    include $SO_RULE_PATH/policy-social.rules
    include $SO_RULE_PATH/protocol-dns.rules
    include $SO_RULE_PATH/protocol-nntp.rules
    include $SO_RULE_PATH/protocol-other.rules
    include $SO_RULE_PATH/protocol-scada.rules
    include $SO_RULE_PATH/protocol-snmp.rules
    include $SO_RULE_PATH/protocol-tftp.rules
    include $SO_RULE_PATH/protocol-voip.rules
    include $SO_RULE_PATH/pua-p2p.rules
    include $SO_RULE_PATH/server-apache.rules
    include $SO_RULE_PATH/server-iis.rules
    include $SO_RULE_PATH/server-mail.rules
    include $SO_RULE_PATH/server-mysql.rules
    include $SO_RULE_PATH/server-oracle.rules
    include $SO_RULE_PATH/server-other.rules
    include $SO_RULE_PATH/server-webapp.rules
    Event thresholding or suppression commands. See threshold.conf
--]]
