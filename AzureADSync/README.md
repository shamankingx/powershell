<h1 align="center">Different of 'Invoke-Command' and 'New-S=PSSession'</h1>

'Invoke-Command' and 'New-PSSession' are both used to run commands on remote machines, but they serve different purposes and offer different features. Here's a detailed comparison:

<h3 align="left">'Invoke-Command'</h3>
Invoke-Command is designed to run commands or scripts on remote computers. It creates a temporary session for each command execution and then tears it down when the command completes. This is useful for one-time or infrequent command executions.

<h3 align="left">Key Points:</h3>
- **Temporary Sessions:** Each 'Invoke-Command' execution creates a temporary session.
- **One-time Execution:** Ideal for running individual commands or scripts without needing a persistent session.
- **Simpler Syntax:** Easy to use for quick remote executions.
- **Parallel Execution:** Can execute commands on multiple remote computers simultaneously.

<h3 align="left">Example:</h3>

```
# Running a command on a single remote computer
Invoke-Command -ComputerName "RemoteServerName" -ScriptBlock { Get-Process }

# Running a command on multiple remote computers
Invoke-Command -ComputerName "Server1", "Server2", "Server3" -ScriptBlock { Get-Process }
```

<h3 align="left">'New-PSSession'</h3>
New-PSSession creates a persistent session with a remote computer. This session can be reused multiple times, which is useful for running a series of commands or maintaining a long-term connection.

<h3 align="left">Key Points:</h3>
- **Persistent Sessions:** Creates a session that persists until explicitly closed.
- **Reusability:** Useful for running multiple commands over time without reconnecting.
- **Complex Tasks:** Ideal for scenarios requiring a sequence of commands or maintaining state.
- **More Overhead:** Requires managing the session lifecycle (creation, reuse, and closure).

<h3 aligh="left">Example:</h3>

```
# Creating a persistent session
$session = New-PSSession -ComputerName "RemoteServerName"

# Running multiple commands within the session
Invoke-Command -Session $session -ScriptBlock { Get-Process }
Invoke-Command -Session $session -ScriptBlock { Get-Service }

# Closing the session when done
Remove-PSSession $session
```

<h3 align="left">Choosing Between Invoke-Command and New-PSSession</h3>

**Use Invoke-Command when:**

You need to run a single command or script on one or more remote computers.
You don't need to maintain a persistent session or state.
Simplicity and ease of use are priorities.

**Use New-PSSession when:**

You need to run multiple commands over time and want to avoid reconnecting.
You require maintaining state or a persistent connection.
The task involves a complex sequence of commands.

<h3 align="left">Summary</h3>
**Invoke-Command** is ideal for one-off or infrequent command executions on remote machines.
**New-PSSession** is suitable for scenarios requiring persistent sessions and multiple command executions over time.
Choosing the appropriate method depends on your specific needs and the complexity of the tasks you need to perform on remote servers.
