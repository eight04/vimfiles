VIM quiz: `map`, `normal`, and `execute`
========================================

I just completed the tutorial - [Learn Vimscript the Hard Way](https://learnvimscriptthehardway.stevelosh.com/) by Steve Losh - and found that I'm still unfamiliar with `map`, `normal`, and `execute`. After searching and testing, I made this quiz.

By answering these questions, you will *fully* understand how to use `map`, `normal`, and `execute` all together.

### Q1.

Put following code in your vimrc:
```vim
nnoremap <F6> :echo 'hi'<CR>
```

<details>
<summary>
   What do you get when triggering the hotkey?
</summary>

VIM echos `hi` when you press `<F6>`.
</details>

### Q2.

Put following code in your vimrc:
```vim
nnoremap <F6> echo 'hi'<CR>
```
<details>
<summary>
  What do you get when triggering the hotkey? Someone said that you don't need colons for commands in VIM scripts. Why it doesn't work here?
</summary>

It presses 10 keys:

* `e` - move forward to the end of a word.
* `ch` - `c` is an operator and `h` is a motion. It deletes a char before the cursor then start the insert mode. Read `:h operator` for `c`. Read `:h left-right-motion` for `h`.
* `o 'hi'` - these are inserted to your document.
* `<CR>` - press enter, which insert a new line.

`map`/`noremap` commands process these chars as a series of key press. `:` is required since we want to switch to the command mode before typing `echo 'hi'`. In this situation, `:` is not part of the command but a key to switch to command mode from the normal mode.

> Extra: You can press `<Esc>` to switch to normal mode from insert mode. Try building a `inoremap` command that echos `hi`.

> Extra 2: Per pervious extra. You can also use `<Ctrl-O>` to switch to normal mode. Read `:help i_CTRL-O` and use it in your `inoremap` command.

> Extra 3: You can use a special key `<Cmd>` to enter a *hidden* command mode. Read `:help <Cmd>` and use it in your `inoremap` command.
</details>

### Q3.

Put following code in your vimrc:
```vim
nnoremap <F6> :echo 'hi'
```
<details>
<summary>
Does it echo <code>hi</code>? why not?
</summary>

Without `<CR>` a.k.a. the enter key, the command typed in the command mode won't be executed. Your cursor results in the command mode with the command `echo 'hi'`.

You will see lots of sample code on the net that forget to `<CR>` after entering the command mode. They are wrong.

> Extra: Try `nnoremap <F6> :echo 'h<Left>i<Right><Right>'<CR>`. What do you get? Read `:h <>`.

> Extra 2: Build a `nnoremap` command that echos `'<CR>'` literally. Hint: `<lt>`.
</details>

### Q4.

Run the following command:
```vim
normal echo 'hi'
```
<details>
<summary>
  Does it work?
</summary>

Nope.
</details>

### Q5.

<details>
<summary>
  Per Q4. Add the missing colon. You should know why the colon is needed after Q2. Does it work? Hint: it doesn't. Why not?
</summary>

It doesn't work since it doesn't press enter. Similar to Q3.

`normal` is like `map`/`remap` but is more limited. It processes the following chars as a series of key type *without parsing special keys in `<>`*.

> Extra: What will you get with `normal i<CR>`? Predict the result before trying it.
</details>

### Q6.

Run the following command:
```vim
execute "echo 'hi'"
```

<details>
<summary>
  Does it work?
</summary>

Yes.

`execute` takes a string as the argument and evaluate the string as a command. It doesn't switch VIM mode. It doesn't type in the command line. Hence you don't have to tell it to press enter to execute the command.
</details>

### Q7.

Run the following command:
```vim
execute "normal :echo 'hi'"
```
<details>
<summary>
  Does it work?
</summary>
  
No.

This executes a normal command that switches to the command mode with `:` and type `echo 'hi'`, without pressing the enter key.
</details>

### Q8.

Run the following command:
```vim
execute "normal echo 'hi'\r"
```
<details>
  <summary>Does it work?</summary>

Yes.

By adding a `"\r"` in the string, we actually feed an enter key to `normal`, which is impossible without the `execute` command.

> Extra: Read `:h expr-string`. How do we feed `<Esc>` to `normal`?

> Extra 2: Run `echo "\e" ==# "\x1b"`.

> Extra 3: Run `echo "\e" ==# "\<Esc>"`.

> Extra 4: Do you remember `<Cmd>` in Q2 extra? Run `execute "normal \<Cmd>echo 'hi'\r"`.
</details>

### Q9.

Put following code in your vimrc:
```vim
nnoremap <F6> :execute "normal :echo 'hi'\r"<CR>
```
<details>
<summary>
  Are those colons necessary?
</summary>

Yes. We use them to switch to the command mode from the normal mode.
</details>

<details>
<summary>
  <code>&lt;CR></code> is handled by which command? What will happen if we remove it?
</summary>

`<CR>` is handled by `nnoremap`. If we remove `<CR>`, the cursor will stay in the command mode and you will see `:execute "normal :echo 'hi'\r"` in the command line.
</details>

<details>
<summary>
<code>\r</code> is handled by which command? What will happen if we remove it?
</summary>

`\r` is handled by `normal`. Without `\r`, the `normal` command won't press enter after typing `:echo 'hi'`.
</details>

### Extra. Control Characters

You can tell VIM to generate a control character. Press following keys in normal mode:

```vim
:normal i<Ctrl-V><Enter>
```

Your cursor should stay at command mode, and you will see something like this:

```vim
:normal i^M
```

Press enter again to execute the command and you will see a new line is inserted. Which means we can build our `:normal :echo` without `:execute`:

```vim
nnoremap <F6> :normal :echo 'hi'<C-V><CR><CR>
```

If you are writing functions, you can even put control characters in your source

```vim
nnoremap <F6> :call SayHi()<CR>

function SayHi()
  " Press <Ctrl-V><Enter> in the insert mode to generate the control character '^M'
  normal :echo 'hi'^M
endfunction
```

However, I strongly encourage avoiding them.

1. Readibility. When building `map`/`remap` commands, `:execute "normal \r"<CR>` is way more readable than `:normal <C-V><CR><CR>`.
2. Portability. Not all applications and editors can process control characters correctly. Like the above code example of `SayHi()`, you can't just copy-paste them to your vimrc but have to switch to insert mode and press `<Ctrl-V><Enter>` in your VIM to get the actual control character. Because the web browser doesn't put control characters on screen, and doesn't feed them to your clipboard.

Read `:h 24.8`.
