int main() {
for (auto x = 100
; x != 0; x = x - 1
){
if (x % 2 == 0){
continue;}
printf("%d%s", x, "\n");
}
return 0;
}
