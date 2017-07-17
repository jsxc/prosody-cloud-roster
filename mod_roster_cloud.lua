local https = require "ssl.https"
local timer = require 'util.timer';
local url = module:get_option_string('roster_cloud_url')
local secret = module:get_option_string('roster_cloud_secret')

module:require "sha1"
local JSON = module:require "json"

local function sendRequest(username)
	local request_body = 'username='..username..'&operation=shared_roster'
	local response_body = {}

	local signature = hmac_sha1(secret, request_body)

	local r, status = https.request({
		url = url,
		source = ltn12.source.string(request_body),
		sink = ltn12.sink.table(response_body),
		method = 'POST',
		headers = {
			["content-type"] = "application/x-www-form-urlencoded",
			["Content-Length"] = string.len(request_body),
			["X-JSXC-SIGNATURE"] = 'sha1='..signature
		}
	})

	return table.concat(response_body), status
end

local function inject_roster_contacts(username, host, roster)
	module:log('debug', 'inject roster contacts for '..username)

	local body, status = sendRequest(username)

	if status ~= 200 then
		module:log('error', body)
		return
	end

	local response = JSON:decode(body)

	if response.result == 'error' then
		module:log('error', response.data.msg);
	end

	if response.result == 'success' then
		for uid, entry in pairs(response.data.sharedRoster) do
			local jid = uid..'@'..host
			if not (jid == username..'@'..host or roster[jid]) then
				module:log('debug', 'injecting '..jid..' as '..entry.name)

				roster[jid] = {};
				local r = roster[jid];
				r.subscription = 'both';
				r.persist = false;
				r.name = entry.name;
				r.groups = {}

				for index, group in ipairs(entry.groups) do
					r.groups[group] = true
				end
			end
		end
	end

	if roster[false] then
		roster[false].version = true;
	end
end

function module.load()
	if url == nil then
		module:log('debug', 'Disabled, because we have no url')
		return
	end

	module:log('debug', 'Loaded. Useing the following endpoint: '..url)

	module:hook('roster-load', inject_roster_contacts);
end

function module.unload()

end
