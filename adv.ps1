# Enable strict mode for robust scripting 
Set-StrictMode -Version Latest

# Set the API key
$xai_api_key = "xai-1YU6eJGnUgOKmJR6IkBl3zaPy5fNKGjFtN8Dg4zPkdvssXtqWEIlY8zb6LHlS9v7XE9uXVSz3T0h80kQ"
# Get the content from the clipboard
$clipboardContent = Get-Clipboard
# Write the JSON payload to a temporary file
$json_file = [System.IO.Path]::Combine($env:TEMP, "payload.json")
$json_payload = @{
    messages = @(
        @{
            role    = "system"
            content = "Your job is to correct grammar.Strict Grammar Enforcement: Provide only grammatically correct responses, ensuring correct spelling, punctuation, and sentence structure.
No Error Acknowledgment: Do not mention or correct user errors unless explicitly asked.
Maintain Clarity: Ensure the response is clear, concise, and correctly structured. do not use any formatting"
        },
        @{
            role    = "user"
            content = "Please correct grammar               "+$clipboardContent
        }
    )
    model       = "grok-beta"
    stream      = $false
    temperature = 0
} | ConvertTo-Json -Depth 10 -Compress
Set-Content -Path $json_file -Value $json_payload

# Define headers
$headers = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer $xai_api_key"
}

# Make the HTTP request using Invoke-RestMethod
$response = Invoke-RestMethod -Uri "https://api.x.ai/v1/chat/completions" `
    -Method Post `
    -Headers $headers `
    -Body (Get-Content -Path $json_file -Raw)

# Cleanup the temporary JSON file
Remove-Item -Path $json_file -Force

# Extract the content field
$content = $response.choices[0].message.content

# Set the content to the clipboard
Set-Clipboard -Value $content
