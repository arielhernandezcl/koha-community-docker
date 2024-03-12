#!/bin/bash

# Start Apache web server
service apache2 start

# Other initialization commands if needed

# Keep the container running
tail -f /dev/null
