-- LJSyscall
package.path = "ljsyscall/?.lua;" .. package.path
return require"syscall"
