-- LJSyscall
package.path = "lib/ljsyscall/?.lua;" .. package.path
return require"syscall"
