
local JSON              = require "common.json"
local kolib             = require "common.kolib"
local connection        = require "connect.connection_open"
local errcode           = require "common.errcode"


local conns = {}
local callback          = ngx.var.arg_callback or ngx.null
local response          = {}
local respJson

local params            = {"gameID", "userID"}
local args              = kolib.getReqParam(ngx.req)
local req = args
local ok, err           = kolib.check_req(params, args)
if not ok then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.wrong_param, err,conns)
    return
end


---------------------------------------------get redis start


local red, err = connection.getRedis()
if not red then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.other_fault, "get redis failed",conns)
    return
end
conns.red = red

local key               = "ko.user." .. req["userID"]
local res, err          = conns.red:hmget(key, "user_token")
if not res then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.other_fault, "Connect to redis server failed!",conns)
    return
end

if res == ngx.null then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.other_fault, "no this user!",conns)
    return
end

---------------------------------------------get redis end

local myconn,err          = connection.getMysql(nil)
if not myconn then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.other_fault, "Connect to MySQL server (pay) failed! "..err,conns)
    return
end
conns.my               = myconn


---------------------------------------------get product_info start

local sql = "select gameID,productID from `test`.`product_info`"
local res, err, errno, sqlstate = conns.my:query(sql)
if not res then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.other_fault, err,conns)
end

if #res == 0 then
    kolib.say_bye_err_exit_with_release_conn(callback,errcode.no_this_game,  "no_this_game",conns)
end

---------------------------------------------get product_info end

kolib.response_success_jsonp_exit_with_release_conn(res,nil,conns)



