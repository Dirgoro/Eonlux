#!/bin/sh
if command -v plymouth >/dev/null 2>&1 && plymouth --ping 2>/dev/null; then
    plymouth update --status="complete" 2>/dev/null || true
    sleep 0.35
    chvt 7 2>/dev/null || true
    plymouth quit 2>/dev/null || true
else
    chvt 7 2>/dev/null || true
fi
