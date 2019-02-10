#!/bin/sh

release_ctl eval --mfa "MineSweep.ReleaseTasks.migrate/1" --argv -- "$@"
