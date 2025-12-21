# 1. Fetch the encoded password from the K8s Secret
$encodedPassword = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"

# 2. Check if the secret exists to avoid errors
if ($null -eq $encodedPassword -or $encodedPassword -eq "") {
    Write-Host "Error: Secret 'argocd-initial-admin-secret' not found or password field is empty." -ForegroundColor Red
    Write-Host "Check pod status using: kubectl get pods -n argocd" -ForegroundColor Yellow
    exit
}

# 3. Decode from Base64 to UTF8 string
try {
    $decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPassword))

    # 4. Print to screen
    Write-Host "----------------------------------------"
    Write-Host "ArgoCD Admin Password Successfully Decoded" -ForegroundColor Green
    Write-Host "Password: " -NoNewline
    Write-Host $decodedPassword -ForegroundColor Cyan
    Write-Host "----------------------------------------"
}
catch {
    Write-Host "Error: Failed to decode Base64 string." -ForegroundColor Red
}