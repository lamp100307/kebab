; ModuleID = "kebab"
target triple = "x86_64-pc-linux-gnu"
declare i32 @printf(i8*, ...)



define i32 @main() {
entry:
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = load i32, i32* %1, align 4
  %3 = icmp eq i32 %2, 0
  br i1 %3, label %label1, label %label3
label1:
  %4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str1, i32 0, i32 0))
  br label %label3
label3:
  ret i32 0
}

@.str = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@.str1 = private unnamed_addr constant [5 x i8] c"zero\00", align 1