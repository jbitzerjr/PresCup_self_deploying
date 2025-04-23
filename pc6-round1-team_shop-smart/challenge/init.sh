#!/bin/bash

ADJECTIVES="fuzzy tartan haunted evil cryptic dumb cursed filthy moldy broken"
NOUNS="squirrel chainsaw gremlin possum priest curse toaster goblin"

FLAG_LOG="./current_tokens.txt"
> "$FLAG_LOG"

TARGET_DIR="./s-mart-webserver"

# Detect Docker Compose (v2 preferred)
if command -v docker compose >/dev/null 2>&1; then
  DOCKER_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DOCKER_CMD="docker-compose"
else
  echo "[!] Neither Docker Compose V2 nor V1 found. Please install Docker Compose."
  exit 1
fi

# Find all files with ######## inside the challenge dir
PLACEHOLDER_FILES=$(find "$TARGET_DIR" -type f -exec grep -l "########" {} +)

i=1
for FILE in $PLACEHOLDER_FILES; do
  COUNT=$(grep -o "########" "$FILE" | wc -l)
  for _ in $(seq 1 $COUNT); do
    ADJ=$(shuf -n1 -e $ADJECTIVES)
    NOUN=$(shuf -n1 -e $NOUNS)
    HEX=$(hexdump -n 2 -e '4/1 "%02x"' /dev/urandom)
    FLAG="{flag} ${ADJ}-${NOUN}-${HEX}"

    awk -v flag="$FLAG" '
      BEGIN { replaced=0 }
      {
        if (!replaced && /########/) {
          sub(/########/, flag)
          replaced=1
        }
        print
      }
    ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

    SHORTFILE=$(realpath --relative-to=. "$FILE")
    echo "FLAG $i ($SHORTFILE): $FLAG" >> "$FLAG_LOG"
    i=$((i+1))
  done
done

echo "[+] Flag injection complete."
echo "[+] Flags written to $FLAG_LOG"

# Start the container
echo "[+] Starting challenge container using: $DOCKER_CMD"
(cd "$TARGET_DIR" && $DOCKER_CMD up -d) || {
  echo "[!] Docker Compose failed to start the challenge."
  exit 1
}
