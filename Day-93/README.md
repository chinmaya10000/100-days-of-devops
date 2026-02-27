# Nautilus DevOps — Ansible: Host-specific file copy using when conditionals

This repository demonstrates how the Nautilus DevOps team can use Ansible `when` conditionals to copy different files to different application servers while running a single play against all hosts.

## Repository layout

/home/thor/ansible/
- `inventory`                ← Ansible inventory (provided)
- `playbook.yml`             ← Playbook that copies files by hostname

Source files (on the jump host):
- `/usr/src/security/blog.txt`
- `/usr/src/security/story.txt`
- `/usr/src/security/media.txt`

## Purpose

Run one play against all Stratos DC application servers and, using `when` conditionals based on `ansible_nodename` (gathered facts), copy a different file to each app server with the required ownership and permissions.

- stapp01 -> copy `blog.txt` to `/opt/security/blog.txt` (owner/group: `tony`, mode `0755`)
- stapp02 -> copy `story.txt` to `/opt/security/story.txt` (owner/group: `steve`, mode `0755`)
- stapp03 -> copy `media.txt` to `/opt/security/media.txt` (owner/group: `banner`, mode `0755`)

## Playbook location

`/home/thor/ansible/playbook.yml`

The play uses:
- `hosts: all`
- `become: yes`
- `when: ansible_nodename == "<fully-qualified-hostname>"`

Facts are gathered by Ansible by default so `ansible_nodename` is available.

## Prerequisites

- Ansible installed on the jump host.
- SSH access from the jump host to all managed nodes as configured in `/home/thor/ansible/inventory`.
- The source files exist on the jump host in `/usr/src/security/`.
- Target directory `/opt/security/` is writable by root (the play uses privilege escalation).

## How to run

From the playbook directory (or provide full paths):

cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml

No extra variables are required.

## Example verification steps

On the jump host you can verify with ad-hoc Ansible commands or by SSH-ing to each host:

- Using Ansible ad-hoc:
  - Check file on stapp01:
    ansible -i inventory stapp01 -m stat -a "path=/opt/security/blog.txt" --become
  - Check file on stapp02:
    ansible -i inventory stapp02 -m stat -a "path=/opt/security/story.txt" --become
  - Check file on stapp03:
    ansible -i inventory stapp03 -m stat -a "path=/opt/security/media.txt" --become

- Or SSH into each host and run:
  ls -l /opt/security/
  stat -c "%U %G %a %n" /opt/security/<file>

Expected output for each file shows the configured owner, group, and mode `755`.

## Notes and troubleshooting

- If a task does not run on a host, confirm the host's `ansible_nodename` (you can print facts with `ansible -m setup`).
- Ensure source files exist at `/usr/src/security/` on the jump host before running the playbook.
- If permission/ownership changes fail, confirm `become` is working and the become user has rights to set ownership (`chown`) on the target path.
