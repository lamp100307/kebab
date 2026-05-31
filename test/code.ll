declare i32 @printf(i8*,...)
@.str.str = private unnamed_addr constant [4 x i8] c"%s\0A\00"

@.s0 = private unnamed_addr constant [8 x i8] c"Hello, \00"
@.s1 = private unnamed_addr constant [7 x i8] c"World!\00"
@.s2 = private unnamed_addr constant [14 x i8] c"Hello, World!\00"

define i32 @main() {
entry:
  %t0 = getelementptr inbounds [8 x i8], [8 x i8]* @.s0, i32 0, i32 0
  %t1 = getelementptr inbounds [7 x i8], [7 x i8]* @.s1, i32 0, i32 0
  %t2 = getelementptr inbounds [14 x i8], [14 x i8]* @.s2, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.str, i32 0, i32 0), i8* %t2)
  ret i32 0
}