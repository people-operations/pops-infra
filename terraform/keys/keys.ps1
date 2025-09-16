$keysPath = (Get-Location).Path

$publicManagementKeyPath = Join-Path $keysPath "key-ec2-public-management-pops.pem"
$publicAnalysisKeyPath = Join-Path $keysPath "key-ec2-data-analysis-pops.pem"
$privateKeyPath = Join-Path $keysPath "key-ec2-private-pops.pem"

ssh-keygen -t rsa -b 2048 -m PEM -f $publicManagementKeyPath -N "`""
ssh-keygen -t rsa -b 2048 -m PEM -f $publicAnalysisKeyPath -N "`""
ssh-keygen -t rsa -b 2048 -m PEM -f $privateKeyPath -N "`""
