#!/usr/bin/env bash
profile=$(asusctl profile get | grep 'Active profile' | cut -d: -f2 | xargs)
case "$profile" in
    Quiet)
        echo '{"text": "Quiet", "alt": "quiet", "tooltip": "Profile: Quiet", "class": "quiet"}'
        ;;
    Balanced)
        echo '{"text": "Balanced", "alt": "balanced", "tooltip": "Profile: Balanced", "class": "balanced"}'
        ;;
    Performance)
        echo '{"text": "Performance", "alt": "performance", "tooltip": "Profile: Performance", "class": "performance"}'
        ;;
    *)
        echo "{\"text\": \"$profile\", \"alt\": \"unknown\", \"tooltip\": \"Profile: $profile\", \"class\": \"unknown\"}"
        ;;
esac
