---
description: Starts a new development session.
---
<!-- mode:shell -->
```
#!/bin/bash
echo "✅ Session started $(date +%F)"
touch .claude/workspace/logs/$(date +%F)/started
```
