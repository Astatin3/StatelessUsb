$conf = Get-Content .\data.json -Raw | ConvertFrom-Json 
echo "StatelessUsb By ASTATIN3"

$charLowercase = "qwertyuioppasdfghjklzxcvbnm"
$charUppercase = "QWERTYUIOPASDFGHJKLZXCVBNM"
$charNumber = "1234567890"
$charSymbol = "``~!@#$%^&*()_+[]`\{}|;`':`",./<>?"
$fullCharset = $charLowercase + $charUppercase + $charNumber + $charSymbol

function printOpts() {
    echo ""
    echo "0 - Exit"
    echo "1 - Site: $site"
    echo "2 - Username: $user"
    echo "3 - Length: $length"
    echo "4 - Include Lowercase: $isLower"
    echo "5 - Include Uppercase: $isUpper"
    echo "6 - Include Numbers: $isNumber"
    echo "7 - Include Symbols: $isSymbol"
    echo "8 - Print"
    echo "9 - Generate" 
    echo "10 - Save"
}

function selector() {
    printOpts        
    :manual while(1){

        $opt2 = Read-Host -Prompt ">"
        echo ""
        switch($opt2){
            0 {
                return
            }
            1 {$site = Read-Host -Prompt "Site>"}
            2 {$user = Read-Host -Prompt "Username>"}
            3 {$length = Read-Host -Prompt "Length>"}
            4 {$isLower = (Read-Host -Prompt "Include Lowercase>") -eq "True"}
            5 {$isUpper = (Read-Host -Prompt "Include Uppercase>") -eq "True"}
            6 {$isNumber = (Read-Host -Prompt "Include Numbers>") -eq "True"}
            7 {$isSymbol = (Read-Host -Prompt "Include Symbols>") -eq "True"}
            8 {
                printOpts
            }
            9 {
                echo "Enter Master Password"
                $pass = Read-Host -AsSecureString -Prompt ">"
                $pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

                echo "Copied to clipboard"
                Set-Clipboard (RandStr ((toInt $site) + (toInt $user) + (toInt $pass)))
            }
            10 {
                $tempconf = "["
                for($i = 0; $i -lt $conf.length; $i++){
                    if($i -ne 0){ $tempconf += ","}
                    $tempconf += ConvertTo-Json @{
                        site = $conf[$i].site
                        user = $conf[$i].user
                        length = $conf[$i].length
                        lower = $conf[$i].lower
                        upper = $conf[$i].upper
                        number = $conf[$i].number
                        symbol = $conf[$i].symbol
                    }
                }
                $tempconf += ","
                $tempconf += ConvertTo-Json @{
                    site=$site
                    user=$user
                    length=$length
                    lower=$isLower
                    upper=$isUpper
                    number=$isNumber
                    symbol=$isSymbol
                }

                $tempconf += "]"

                echo $tempconf > ./data.json
            }
            default {continue}
        }
    }
}

function toInt($Str){
    $result = ''
    for($i = 0; $i -le $Str.length-1; $i++){
        $result += $fullCharset.IndexOf($Str[$i])
    }

    $result = $result -as [Int64]
    echo $result
}

function RandStr($seed){
    $charset = ''

    if(!$site -or !$user){
        echo "Invalid Configuration"
        return
    }

    if($isLower){ $charset += $charLowercase}
    if($isUpper){ $charset += $charUppercase}
    if($isNumber){ $charset += $charNumber}
    if($isSymbol){ $charset += $charSymbol}

    $result = ''
    for($i = 0; $i -lt $length; $i++){
        $result += $charset[(Rand $seed $i $charset.length)]
    }
    return $result
}

function Rand(){
    param(
        $state1,
        $state2,
        $limit
    )
    
    $mod1=4294967087 -as [Int64]
    $mul1=65539 -as [Int64]
    $mod2=4294965887 -as [Int64]
    $mul2=65537 -as [Int64]
    
    $state1 = $state1 -as [Int64]
    $state2 = $state2 -as [Int64]
    $limit = $limit -as [Int32]

    $state1=$state1 % ($mod1-1)+1
    $state2=$state2 % ($mod2-1)+1
    $state1=($state1*$mul1)%$mod1
    $state2=($state2*$mul2)%$mod2
    if($state1 -lt $limit -and $state2 -lt $limit -and $state1 -lt $mod1%$limit -and $state2 -lt $mod2%$limit){
        return random($limit)
    }
    return (($state1+$state2) % $limit)
}

:main while(1){
    echo ""
    echo "0 - Exit"
    echo "1 - Read existing entry"
    echo "2 - Manual"
    $opt = Read-Host -Prompt ">"
    echo ""

    switch($opt){
        0 {break main}
        1 {
            for($i = 0;$i -le $conf.length-1;$i++){
                echo ([String]$i + " - " + $conf[$i].site)
            }

            while(1){
                $opt = read-host ">"

                if($opt -le $conf.length-1 -and $opt -ge 0){
                    break
                }
                echo "Incorrect option"
            }

            $site = $conf[$opt].site
            $user = $conf[$opt].user
            $length = $conf[$opt].length
            $isLower = $conf[$opt].lower
            $isUpper = $conf[$opt].upper
            $isNumber = $conf[$opt].number
            $isSymbol = $conf[$opt].symbol

            selector
        }
        2 {
            $site = ""
            $user = ""
            $length = 16
            $isLower = $true
            $isUpper = $true
            $isNumber = $true
            $isSymbol = $true
            selector
        }
        default {continue main}
    }
}