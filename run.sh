crave run --no-patch -- bash -c "
curl https://raw.githubusercontent.com/MaheshTechnicals/ROM-Logs/refs/heads/main/script.sh | bash
" &&
crave pull out/target/product/*/*.zip &&
crave pull out/target/product/*/*.img
