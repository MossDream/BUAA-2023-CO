#include <stdio.h>
#define maxn 1000 // 最大位数
int f[maxn];

int main()
{
	int i, j, n, len = 0;
	scanf("%d", &n);
	f[0] = 1; // 初始置于1
	for (i = 2; i <= n; i++)
	{
		int carry = 0; // 定义进位初始为0
		for (j = 0; j <= len; j++)
		{
			int s = f[j] * i + carry; // 乘法结果为乘完加之前的进位
			f[j] = s % 10;
			carry = s / 10; // 获得进位数
		}
		while (carry)
		{
			len++;
			f[len] = carry % 10;
			carry /= 10;
		}
	}
	for (i = len; i >= 0; i--)
	{
		printf("%d", f[i]);
	}
}
