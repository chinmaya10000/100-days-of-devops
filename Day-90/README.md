# Ansible ACL Configuration Playbook

This repository contains an Ansible playbook used to create files on multiple application servers in the Stratos DC and apply ACL (Access Control List) permissions as required.

Directory layout
```
/home/thor/ansible/
│── inventory
│── playbook.yml
└── README.md
```

Objective
- Create specific files on each app server.
- Ensure all files are owned by `root`.
- Apply ACL permissions for corresponding users/groups.
- Run entirely using Ansible.

Server-wise tasks
- stapp01
  - Create: `/opt/itadmin/blog.txt`
  - ACL: grant read (`r`) to group `tony`
- stapp02
  - Create: `/opt/itadmin/story.txt`
  - ACL: grant read+write (`rw`) to user `steve`
- stapp03
  - Create: `/opt/itadmin/media.txt`
  - ACL: grant read+write (`rw`) to group `banner`

Playbook
- The playbook is `playbook.yml` at the repo root and targets `hosts: all`.
- It uses `become: yes` so tasks run with elevated privileges.
- It creates files owned by `root` and sets the requested ACLs using the `acl` module.

Prerequisites
- Ansible installed on the control host (tested with Ansible 2.9+ and newer).
- On target hosts:
  - `acl` support (the setfacl/getfacl utilities). On many distros install the `acl` package, e.g.:
    - Debian/Ubuntu: `apt-get update && apt-get install -y acl`
    - RHEL/CentOS: `yum install -y acl`
- Ensure the remote accounts named in the ACLs exist (e.g., `steve`) or the groups exist (`tony`, `banner`) on the target hosts or via your centralized user/group service (LDAP, etc.).

How to run
From the repository directory (e.g. `/home/thor/ansible`):

```bash
ansible-playbook -i inventory playbook.yml
```

Notes
- The playbook uses `when: inventory_hostname == "stapp01"` (etc.) to run the server-specific tasks only on the right host.
- The `acl` module in Ansible will apply the permissions using `setfacl`. If you prefer idempotence checks, the module handles presence/absence semantics when `state: present`/`absent` is used.

Verify ACLs manually
After running the playbook, on the appropriate server(s):

```bash
getfacl /opt/itadmin/blog.txt
getfacl /opt/itadmin/story.txt
getfacl /opt/itadmin/media.txt
```

Example expected output lines (indicative)
- For blog.txt (stapp01): a line showing `group:tony:r--`
- For story.txt (stapp02): a line showing `user:steve:rw-`
- For media.txt (stapp03): a line showing `group:banner:rw-`
