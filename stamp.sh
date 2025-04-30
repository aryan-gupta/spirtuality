# https://weisser-zwerg.dev/posts/trusted_timestamping/
# https://gist.github.com/Manouchehri/fd754e402d98430243455713efada710
# https://freetsa.org/index_en.php


file="$1"
base_name=$(basename ${file})

query="$base_name.tsq"
reply="$base_name.tsr"

# openssl x509 -inform der -in RootCertificate.cer -out RootCertificate.pem

server="http://timestamp.apple.com/ts01"; root_ca="./AppleIncRootCertificate.pem"  ; ts_ca="./AppleTimestampCA.cer"

openssl ts -query -data $file -no_nonce -sha512 -cert -out $query
curl -H "Content-Type: application/timestamp-query" --data-binary "@$query" $server > $reply
openssl ts -reply -in $reply -text


# verify
# https://weisser-zwerg.dev/posts/trusted_timestamping/#verify-the-timestamp-response-together-with-the-referenced-piece-of-data
openssl ts -verify -queryfile $query -in $reply -CAfile $root_ca -untrusted $ts_ca
openssl ts -verify -queryfile $query -in $reply -CAfile $ts_ca -partial_chain
