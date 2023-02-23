#!/bin/bash

# Set heath check.io URL
URL=" url to ping at healthcheck.io"


# Set the zone ID, record ID, email, and API key
zone_id="your zone ID"
record_id="your record ID"
email="youremail@example.com"
api_key="your API key"
domain_name="example.com"

# Get the current IP address from the Cloudflare DNS record
current_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
  -H "X-Auth-Email: $email" \
  -H "X-Auth-Key: $api_key" \
  -H "Content-Type: application/json" | jq -r '.result.content')

# Get the current public IP address
public_ip=$(curl -s --ipv4 https://ifconfig.co)



# Check if the IP address has changed
if [[ $current_ip != $public_ip ]]; then
  # Update the DNS record with the new IP address
  response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $api_key" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$domain_name\",\"content\":\"$public_ip\",\"ttl\":120,\"proxied\":true}")
    echo   "current ip on cf ${current_ip} true IP ${public_ip}"
    echo $response

  
  # Check if the update was successful
  success=$(echo $response | jq -r '.success')
  if [[ $success == "true" ]]; then
    echo "Cloudflare DNS record updated successfully from ${current_ip} to ${public_ip}"

  else
    echo "Cloudflare DNS record update failed."
  fi
else
  echo "IP address ${current_ip} is up to date on Cloudflare."
  curl --retry 3  $URL
fi
