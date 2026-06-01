declare i32 @printf(i8*,...)
@.str.str = private unnamed_addr constant [4 x i8] c"%s\0A\00"
declare void @kprintbool(i1)

@.s0 = private unnamed_addr constant [14 x i8] c"x not true :(\00"

define i32 @main() {
entry:
  %x = alloca i1
  store i1 true, i1* %x
  %t0 = load i1, i1* %x
  br i1 %t0, label %if.then_0, label %if.else_1
if.then_0:
  %t1 = load i1, i1* %x
  call void @kprintbool(i1 %t1)
  br label %if.end_2
if.else_1:
  %t2 = getelementptr inbounds [14 x i8], [14 x i8]* @.s0, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.str, i32 0, i32 0), i8* %t2)
  br label %if.end_2
if.end_2:
  store i1 false, i1* %x
  %t3 = load i1, i1* %x
  br i1 %t3, label %if.then_3, label %if.else_4
if.then_3:
  %t4 = load i1, i1* %x
  call void @kprintbool(i1 %t4)
  br label %if.end_5
if.else_4:
  %t5 = getelementptr inbounds [14 x i8], [14 x i8]* @.s0, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.str, i32 0, i32 0), i8* %t5)
  br label %if.end_5
if.end_5:
  ret i32 0
}