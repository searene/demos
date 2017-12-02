title: Some Linux Commands
date: 2017-10-05 08:37:42
tags: linux
categories: Coding
thumbnail: /images/xl-2017-linux-1.jpg
---

# :-

Take `${val1:-val2}` for example, if `val1` is unset or null, return `val2`, otherwise return `val1`.

Example:

```bash
#!/bin/bash

default="default"
preset="preset"
value="This is ${preset:-"$default"} value"
echo $value  # This is preset value
```

```bash
#!/bin/bash

default="default"
value="This is ${preset:-"$default"} value"
echo $value  # This is default value
```

# set -a

Definition from the [Bash Manual](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin)

> `-a`
>
> Each variable or function that is created or modified is given the export attribute and marked for export to the environment of subsequent commands.

Honestly I haven't fully comprehended the definition, but we can set up an example to see what it does.

1. Create `foo.sh`

   ```bash
   #!/usr/bin/env bash

   set -a
   . "./bar.sh"
   set +a
   echo "a=$a"
   echo "b=$b"
   echo "c=$c"
   ```

2. Create `bar.sh`

   ```bash
   #!/usr/bin/env bash

   a=1
   b=2
   c=3
   ```

3. Set executable permission

   ```bash
   chmod +x foo.sh
   chmod +x bar.sh
   ```

4. Source `foo.sh`

   ```bash
   . ./foo.sh
   ```

5. Result

   ```bash
   a=1
   b=2
   c=3
   ```

   As you can see, we can access all the variables defined in `bar.sh` in `foo.sh`, just as if they are marked as `export`. If we didn't use `set -a`, the result would be

   ```bash
   a=
   b=
   c=
   ```

6. We can access it directly in the terminal too, they are exported all the way to the top bash environment.

   ```bash
   ➜  /tmp echo $a
   1
   ➜  /tmp echo $b
   2
   ➜  /tmp echo $c
   3
   ```

# Bash Regular Expressions

We can use regular expressions with the help of `=~`, here is an example.

```bash
#!/usr/bin/env bash

foo=1
if [[ $foo =~ [[:digit:]]+$ ]]; then
    echo number
fi
```

**Output**

```bash
number
```

Notice that you cannot use `\d` or `\\d` to replace `[[:digit:]]`, because `\d` is PCRE, while it uses POSIX regex here, which doesn't recognize `\d`. If you think `[[:digit:]]` is too long, you can use `[0-9]` to replace it, which has the same effect.

```bash
#!/usr/bin/env bash

foo=1
if [[ $foo =~ [0-9]+$ ]]; then
    echo number
fi
```

**Output**

```
number
```