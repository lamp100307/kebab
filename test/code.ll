declare i32 @printf(i8*,...)
@.str.int = private unnamed_addr constant [4 x i8] c"%d\0A\00"


define i32 @main() {
entry:
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.int, i32 0, i32 0), i32 1)
  ret i32 0
}