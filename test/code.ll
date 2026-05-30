; ModuleID = "kebab"
target triple = "x86_64-pc-linux-gnu"
declare i32 @printf(i8*, ...)



define i32 @main() {
entry:
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  br label %label1
label1:
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str1, i32 0, i32 0))
  %3 = load i32, i32* %1, align 4
  %4 = add i32 %3, 1
  store i32 %4, i32* %1, align 4
  %5 = load i32, i32* %1, align 4
  %6 = icmp eq i32 %5, 10
  br i1 %6, label %label3, label %label5
label3:
  br label %label2
  br label %label5
label5:
  br label %label1
label2:
  ret i32 0
}

@.str = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@.str1 = private unnamed_addr constant [5 x i8] c"Loop\00", align 1