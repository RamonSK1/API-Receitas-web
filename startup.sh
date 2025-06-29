#!/bin/bash
pip install -r requirements.txt
gunicorn --bind=0.0.0.0:${PORT:-5000} --workers=4 "app:app"