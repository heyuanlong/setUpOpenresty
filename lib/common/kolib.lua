
module("common.kolib", package.seeall)
local errcode                   = require "common.errcode"
local koconf                    = require "common.koconf"
local JSON                      = require "common.json"

local VERSION           = 20150516 -- version history at end of file
local AUTHOR_NOTE       = "open team"




-- dump table 的工具类
function table_dump(tbl)
    -- assert("table" == type(tbl))
    local tmp ={}
    local i = 1

    if("table" ~= type(tbl)) then
        return tostring(tbl)
    end

    for k, v in pairs(tbl) do
        if("table" == type(v)) then
            tmp[i] = tostring(k).."="..table_dump(v)
        else
            tmp[i] = tostring(k).."="..tostring(v)
        end
        i = i+1
    end
    return "{"..table.concat(tmp," ").."}"
end

-- urldecode
function urldecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

-- urlencode
function urlencode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return s
end




-- 生成小写随机数
function make_random_low(len)
    if len < 0 then
        return nil, "len is not right"
    end

    math.randomseed(os.time())
    local rdc           = ""
    for i = 1, len, 1 do
    rdc                 = rdc..string.char(math.random(97,122))
    end

    return rdc, nil
end

-- 生成大写随机数
function make_random_up(len)
    if len < 0 then
        return nil, "len is not right"
    end

    math.randomseed(os.time())
    local rdc           = ""
    for i = 1, len, 1 do
    rdc                 = rdc..string.char(math.random(65,90))
    end

    return rdc, nil
end


function htmlbindrsp(str)
    local rsp = "<html><script type=\"text/javascript\">var mstr='"..str.."';if(window.account && window.account.vbr){window.account.vbr(mstr);}</script></html>"
    return rsp
end

function htmlloginrsp(str)

    local rsp = "<html><script type=\"text/javascript\">var mstr='"..str.."';if(window.account && window.account.vlr){window.account.vlr(mstr);}</script></html>"
    return rsp
end

function htmlweixintext(name, state)
    local rsp = "<!DOCTYPE html> \
<html> \
<head> \
    <title>UPDATE</title> \
    <script src=\"http://res.wx.qq.com/connect/zh_CN/htmledition/js/wxLogin.js\"></script> \
</head> \
<body style=\"background:none; text-align:center;\" onload=\"onBodyLoaded()\"> \
<div id=\"matchvs_weichat_content\" style=\"width:300px; margin:0 auto;\"> \
</div> \
<script type=\"text/javascript\"> \
    var obj = new WxLogin({ \
        id:\"matchvs_weichat_content\", \
        appid: \"wxd1c2930d6678e072\", \
        scope: \"snsapi_login\", \
        redirect_uri: \"http://user.matchvs.com/wc3/"..name..".do\", \
        state:\""..state.."\", \
        style: \"\", \
        href: \"https://user.matchvs.com/css/wx_style_default.css?\" + new Date().getTime() \
    }); \
 \
    function onBodyLoaded(){ \
        var container = document.getElementById(\"matchvs_weichat_content\"); \
        if(Object.prototype.toString.call( container ) === '[object HTMLDivElement]'){ \
            container.style.width = \"100%\"; \
            container.style.height = \"3000px\"; \
            var iframe = container.firstChild; \
            if(Object.prototype.toString.call( iframe ) === '[object HTMLIFrameElement]'){ \
                iframe.style.width = \"100%\"; \
                iframe.style.height = \"3000px\"; \
            } \
        } \
    } \
</script> \
</body> \
</html>"

    return rsp

end

function read_file(path)
    local f = io.open(path, "r")
    if f == nil then
        return nil, "open file error"
    end

    local rsp = f:read("*all")
    f:close()
    if rsp == nil then
        return nil, "read file error"
    end

    return rsp, nil
end





function get_err_response(err, msg)
    local esp       = {}
    esp["status"]   = 1
    esp["code"]     = err
    esp["msg"]      = msg
    local rsp       = JSON:encode(esp)
    return rsp, nil
end

function get_success_response(info)
    local nsp               = {}
    nsp["status"]           = 0
    nsp["data"]             = info
    local rsp               = JSON:encode(nsp)
    return rsp, nil
end

function say_bye_text_exit(callback, text)
    if not callback or callback == ngx.null then
        ngx.header.content_type = "application/json; charset=utf8"
        ngx.say(text)
    else
        ngx.header.content_type = "application/javascript; charset=utf8"
        ngx.say(callback,"(", text,");")
    end
    ngx.exit(ngx.HTTP_OK)
end

function say_bye_json_exit(callback, response)
    local respJson = JSON:encode(response)
    if not callback or callback == ngx.null then
        ngx.header.content_type = "application/json"
        ngx.say(respJson)
    else
        ngx.header.content_type = "application/javascript"
        ngx.say(callback,"(", respJson,");")
    end
    ngx.exit(ngx.HTTP_OK)
end

function response_err_exit(err, msg)
    local esp       = {}
    esp["status"]   = 1
    esp["code"]     = err
    esp["msg"]      = msg
    local rsp       = JSON:encode(esp)
    ngx.say(rsp)
    ngx.exit(ngx.OK)
    return
end

function response_err_jsonp_exit(err, msg, callback)
    local esp       = {}
    esp["status"]   = 1
    esp["code"]     = err
    esp["msg"]      = msg
    local rsp       = JSON:encode(esp)
    if not callback or callback == ngx.null then
        ngx.header.content_type = "application/json;charset=utf8"
        ngx.say(rsp)
    else
        ngx.header.content_type = "application/javascript;charset=utf8"
        ngx.say(callback,"(", rsp,");")
    end
    ngx.exit(ngx.HTTP_OK)
    return
end


function response_success_exit(info)
    local nsp               = {}
    nsp["status"]           = 0
    nsp["data"]             = info
    local rsp               = JSON:encode(nsp)
    ngx.say(rsp)
    ngx.exit(ngx.OK)
    return
end

function response_success_urlencode_exit(info)
    local nsp               = {}
    nsp["status"]           = 0
    nsp["data"]             = info
    local rsp               = JSON:encode(nsp)
    rsp = urlencode(rsp)
    ngx.say(rsp)
    ngx.exit(ngx.OK)
    return
end

function response_success_jsonp_exit(info, callback)
    local nsp               = {}
    nsp["status"]           = 0
    nsp["data"]             = info
    local rsp               = JSON:encode(nsp)
    if not callback or callback == ngx.null then
        ngx.header.content_type = "application/json;charset=utf8"
        ngx.say(rsp)
    else
        ngx.header.content_type = "application/javascript;charset=utf8"
        ngx.say(callback,"(", rsp,");")
    end
    ngx.exit(ngx.HTTP_OK)
    return
end



function query_start(mysql)
    local sql = "SET AUTOCOMMIT=0; START TRANSACTION;"
    return mysql:execute(sql)
end

function query_rollback(mysql)
    local sql = "ROLLBACK;"
    return mysql:query(sql)
end

function query_commit(mysql)
    local sql = "COMMIT;"
    return mysql:query(sql)
end



function check_req(reqp, req)
    for key, value in pairs(reqp) do
        if req[value] == nil or req[value] == ngx.null then
            return false,"param "..value.." is null"
        end
    end
    return true,nil
end

--该函数检查req数组中参数是否存在，且是否对应reqp数组中的type定义。
--@参数 req           : 待检验参数table
--@参数 param         : 待检参数名与type组成的table 形如：{“param”：“type”}
--@返回 ok            : true为没有错误，false发生错误
--@返回 err           : 错误信息
function check_req2(reqp, req)
    for key, value in pairs(reqp) do
        if req[key] == nil or req[key] == ngx.null then
            return false, "param "..key.." is null"
        else
            local ok, err = check_req_type(req, key, value)
            if not ok then
                return false, err
            end
        end
    end
    return true, nil
end

--该函数验证requset table的参数与其type是否一致。该函数直接被req_check2调用。
--@参数 req           : 待检验参数table
--@参数 param         : 参数名，如req[param]即对应名字为param的参数值
--@参数 type          : 参数类型
--@返回1              : true为没有错误，false发生错误
--@返回2              : 错误信息
function check_req_type(req,param,ptype)
    action = {
      ["string"] = function (t,i)
                        if string.len(t[i]) > 0 then
                            return true
                        else
                            return false
                        end
                    end,
      ["number"] = function (t,i)
                        if string.len(t[i]) > 0 then
                           t[i] = tonumber(t[i])
                            return true
                        else
                            return false
                        end
                    end,
      ["json"] = function (t,i)
                        local status = pcall( function() t[i] = JSON:decode(urldecode(t[i])) end)
                        if not status then
                            return false
                        else
                            return true
                        end
                    end,
    }
    if type(req[param]) == "table" then
        for i, v in pairs(req[param]) do
            if not action[ptype](req[param], i) then
                return false, "the type of param: '"..param.."' is not corresponding to the type: '"..ptype.."' "
            end
        end
    else
        if not action[ptype](req,param) then
            return false,"the type of param: '"..param.."' is not corresponding to the type: '"..ptype.."' "
        end
    end
    return true,nil
end


--该函数从ngx.req获取传入参数，并解析data参数下的JSON字符串（如果有data参数的话），返回参数数组。
--@参数 req           : ngx.req
--@返回1              : req为获取的参数table，false发生错误
--@返回2              : 错误信息
function getReqParam(req)
    req.read_body()
    local garg  = req.get_uri_args()
    local parg = req.get_post_args()

    local args = {}

    for k,v in pairs(garg) do
        --ngx.log(ngx.ERR, "GET KEY [", k, "] = VALUE [", v, "]")
        args[k] = v
    end

    for k,v in pairs(parg) do
        --ngx.log(ngx.ERR, "POST KEY [", k, "] = VALUE [", v, "]")
        args[k] = v
    end
    if args.data then
        local udata = urldecode(args.data)
        local data
        local status,err = pcall(function()   data = JSON:decode(udata) end)
        if not status then
            return nil,err
        end

        for k,v in pairs(data) do
            args[k] = v
        end
    end
    return args
end




function iptonumber(sIP)
    local num = 0
    for elem in sIP:gmatch("%d+") do
        num = num * 256 + assert(tonumber(elem))
    end
    return num
end




-- 通过签名计算，可自定义连接符，首尾字符串
-- 基本签名计算模式： 首字符串分隔符key1=value1分隔符key2=value2分隔符key3=value3分隔符尾字符串
-- key=value按ASCII升序排序
function makeSignCommon(params, separator, headKey, tailKey)
    if type(params) ~= "table" then
        return nil, "first param must be a table"
    end

    separator       = separator or ""
    headKey         = headKey or ""
    tailKey         = tailKey or ""

    local sorted    = {}

    for k,v in pairs(params) do
        table.insert(sorted, k)
    end

    table.sort(sorted)
    local str = headKey..separator

    for i, key in ipairs(sorted) do
        str = str..key.."="..params[key]..separator
    end

    str = str..tailKey

    local value = ngx.md5(str)

    return value, str
end

-- 将Hex化的字符串转化为原本的binary
function hexToBinary(str)
    return (str:gsub("..", function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

-- 转化 yyyy-MM-dd HH:mm:ss 格式的字符串为 时间戳
function convertStringToTimestamp(timeToConvert)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local yyyy, mm, dd, HH, MM, SS = timeToConvert:match(pattern)
    if not yyyy or not mm or not dd or not HH or not MM or not SS then
        return 0
    end
    local convertedTimestamp = os.time({
        year = yyyy, 
        month = mm, 
        day = dd, 
        hour = HH, 
        min = MM, 
        sec = SS
    })
    return convertedTimestamp
end

-- 时区偏差，相较于0区时间
function localTimezoneOffset()
    local ts = os.time()
    local utcdate   = os.date("!*t", ts)
    local localdate = os.date("*t", ts)
    localdate.isdst = false -- this is the trick
    return os.difftime(os.time(localdate), os.time(utcdate))
end

-- byte转化为int
-- endian ["big", "small"]
-- signed [true, false]
function bytes_to_int(str, endian, signed) -- use length of string to determine 8,16,32,64 bits
    local t={str:byte(1,-1)}
    if endian=="big" then --reverse bytes
        local tt={}
        for k=1,#t do
            tt[#t-k+1]=t[k]
        end
        t=tt
    end
    local n=0
    for k=1,#t do
        n=n+t[k]*2^((k-1)*8)
    end
    if signed then
        n = (n > 2^(#t*8-1) -1) and (n - 2^(#t*8)) or n -- if last bit set, negative.
    end
    return n
end

-- int转化为byte
-- endian ["big", "small"]
-- signed [true, false]
function int_to_bytes(num, endian, signed)
    if num<0 and not signed then num=-num print"warning, dropping sign from number converting to unsigned" end
    local res={}
    local n = math.ceil(select(2,math.frexp(num))/8) -- number of bytes to be used.
    if signed and num < 0 then
        num = num + 2^n
    end
    for k=n,1,-1 do -- 256 = 2^8 bits per char.
        local mul=2^(8*(k-1))
        res[k]=math.floor(num/mul)
        num=num-res[k]*mul
    end
    assert(num==0)
    if endian == "big" then
        local t={}
        for k=1,n do
            t[k]=res[n-k+1]
        end
        res=t
    end
    return string.char(unpack(res))
end

-- 根据时间戳创建时间字符串的函数
--@参数 timestamp      : 时间戳，单位可以是秒或毫秒，程序中会做检查
--@返回                : 格式为'2000-01-01 08:08:08'的时间字符串
function getDateTimeByTimestamp(timestamp)
    timestamp = tonumber(timestamp)
     -- lua中的时间戳是到秒，而不是到毫秒，需要作调整
    if timestamp > 1e11 then
        timestamp = timestamp / 1000
    end

    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- 分割字符串的函数
--@参数 str            : 被分割字符串
--@参数 separator      : 分割符
--@返回                : 分割后的字符串组成的数组
function split(str, separator)  
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(str, separator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(str, nFindStartIndex, string.len(str))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(str, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(separator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end


-- 获取未经URL解码的GET请求参数
--@参数 queryString    : GET请求的查询字符串，如'key1=value1&key2=value2&key3=value3'
--@返回                : 请求参数构成的字典
function getRawGetParams(queryString)
    local params = {}
    local keyValues = split(queryString, '&')
    for i, keyValue in ipairs(keyValues) do
        local keyValueArr = split(keyValue, "=")
        params[keyValueArr[1]] = keyValueArr[2] or ""
    end
    return params
end

function releaseConns(conns, tags)
    for index,v in pairs(conns) do
        local ok, err           = v:set_keepalive(10000, 100)
        if not ok then
            v:close()
        end
    end
    return true, nil, nil
end

function say_bye_err_exit_with_release_conn( callback,errCode,msg,conns )
    local respJson = get_err_response(errCode, msg)
    releaseConns(conns,nil)
    say_bye_text_exit(callback, respJson)
end
function response_success_jsonp_exit_with_release_conn( info, callback,conns )
    releaseConns(conns,nil)
    response_success_jsonp_exit(info,callback)
end