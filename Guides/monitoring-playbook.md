# Real-time Security Monitoring Playbook

## Objective
Set up comprehensive security monitoring for the NCAE Cyber Games infrastructure to detect and respond to potential red team activities.

## Monitoring Components

### 1. Log Monitoring
- Monitor `/var/log/auth.log` for:
  - Failed login attempts
  - SSH connection attempts
  - Sudo usage
  - User creation/deletion
  - Password changes

- Monitor `/var/log/apache2/error.log` for:
  - Failed web access attempts
  - SQL injection attempts
  - XSS attempts
  - Directory traversal attempts

- Monitor `/var/log/mysql/error.log` for:
  - Failed database connections
  - SQL injection attempts
  - Unauthorized access attempts

### 2. Network Monitoring
- Monitor for:
  - Port scans
  - Brute force attempts
  - Suspicious IP addresses
  - Unusual traffic patterns
  - Data exfiltration attempts

### 3. System Monitoring
- Monitor for:
  - File system changes
  - New user accounts
  - Modified system files
  - Unusual process activity
  - Resource usage spikes

## Real-time Alerts

### Critical Alerts (Immediate Response Required)
1. Multiple failed login attempts
2. Successful root login
3. New user account creation
4. File system modifications
5. Port scan detection
6. Brute force attempts
7. Suspicious network connections

### Warning Alerts (Investigation Required)
1. High CPU/Memory usage
2. Failed service starts
3. Configuration changes
4. Unusual log patterns
5. Multiple connection attempts

## Response Procedures

### Immediate Actions
1. Block suspicious IP addresses
2. Lock compromised accounts
3. Investigate file changes
4. Review system logs
5. Check for malware

### Investigation Steps
1. Review relevant logs
2. Check system integrity
3. Verify user accounts
4. Analyze network traffic
5. Document findings

## Monitoring Tools

### Active Monitoring
```bash
# Monitor auth logs in real-time
tail -f /var/log/auth.log | grep -i "failed\|error\|warning"

# Monitor Apache logs
tail -f /var/log/apache2/error.log | grep -i "error\|warning"

# Monitor system processes
top -b -n 1

# Check failed login attempts
lastb | head -n 20

# Monitor network connections
netstat -tuln
```

### Daily Checks
```bash
# Check for rootkit
rkhunter --check

# Check file integrity
aide --check

# Review failed login attempts
faillock

# Check firewall status
ufw status verbose

# Review audit logs
ausearch -ts today
```

## Incident Response

### 1. Detection
- Monitor alerts
- Review logs
- Check system status

### 2. Analysis
- Identify the threat
- Assess impact
- Document findings

### 3. Response
- Block threats
- Mitigate vulnerabilities
- Update security measures

### 4. Recovery
- Restore affected systems
- Update security policies
- Document lessons learned

## Maintenance

### Daily Tasks
1. Review security alerts
2. Check system logs
3. Update security tools
4. Monitor system performance
5. Review firewall rules

### Weekly Tasks
1. Full system scan
2. Log analysis
3. Security tool updates
4. Policy review
5. Backup verification

### Monthly Tasks
1. Security assessment
2. Policy updates
3. Tool evaluation
4. Incident review
5. Training updates

## Documentation

### Required Records
1. Security incidents
2. System changes
3. Policy updates
4. Tool configurations
5. Response procedures

### Reporting
1. Daily status reports
2. Weekly security summary
3. Monthly assessment
4. Incident reports
5. Improvement recommendations

## Tools and Resources

### Monitoring Tools
- Snort IDS
- Suricata IPS
- AIDE
- Fail2ban
- RKHunter
- Lynis

### Log Management
- rsyslog
- auditd
- journalctl

### Network Tools
- tcpdump
- netstat
- nmap
- wireshark

### System Tools
- top
- htop
- iotop
- iftop

## Emergency Contacts

### Technical Support
- Team Lead: [Contact Info]
- System Admin: [Contact Info]
- Security Lead: [Contact Info]

### External Support
- Competition Officials: [Contact Info]
- Emergency Response: [Contact Info]
- Backup Support: [Contact Info]

## Notes
- Keep this playbook updated
- Document all incidents
- Regular team training
- Update contact information
- Review and revise procedures

**END OF PLAYBOOK**

