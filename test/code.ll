; ModuleID = "kebab"
target triple = "x86_64-pc-linux-gnu"
declare i32 @printf(i8*, ...)



define i32 @main() {
entry:
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  br label %label1
label1:
  %2 = load i32, i32* %1, align 4
  %3 = icmp sle i32 %2, 10
  br i1 %3, label %label2, label %label4
label2:
  %4 = load i32, i32* %1, align 4
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %4)
  br label %label3
label3:
  %6 = load i32, i32* %1, align 4
  %7 = add i32 %6, 1
  store i32 %7, i32* %1, align 4
  br label %label1
label4:
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str1, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str2, i32 0, i32 0))
  %9 = alloca i32, align 4
  store i32 1, i32* %9, align 4
  br label %label5
label5:
  %10 = load i32, i32* %9, align 4
  %11 = icmp slt i32 %10, 2048
  br i1 %11, label %label6, label %label7
label6:
  %12 = load i32, i32* %9, align 4
  %13 = mul i32 %12, 2
  store i32 %13, i32* %9, align 4
  %14 = load i32, i32* %9, align 4
  %15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %14)
  br label %label5
label7:
  ret i32 0
}

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str1 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@.str2 = private unnamed_addr constant [4 x i8] c"End\00", align 1