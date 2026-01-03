$env:DATABASE_URL="file:../dev.db"
# Note: I moved dev.db up one level or keep it relative. Let's keep it ./dev.db
$env:DATABASE_URL="file:./dev.db"
Write-Host "Setting DATABASE_URL to $env:DATABASE_URL"
npx prisma db push
