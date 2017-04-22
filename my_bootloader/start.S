#define S3C2440_MPLL_400MHZ     ((0x5c<<12)|(0x01<<4)|(0x01))
#define MEM_CTL_BASE    0x48000000

.text
.global _start
_start:

/* 1. �ؿ��Ź� ����Ĵ���WTCON(0x53000000)д0���ɣ�P462��*/
	ldr r0, =0x53000000       //��0x53000000����r0��
	mov r1, #0                //��0����r1�У�
	str r1, [r0]              //��r1�е�0����r0��ָ�Ĵ洢���У�

/* 2. ����ʱ�ӣ����üĴ���CLKDIVN(0x4C000014)���÷�Ƶ��P260�� */
	ldr r0, =0x4c000014
	mov r1, #0x05;			  // FCLK:HCLK:PCLK=1:4:8
	str r1, [r0]

/* ���HDIVN��0��CPU������ģʽӦ����Ϊ��asynchronous bus mode��;P244 */
	mrc	p15, 0, r1, c1, c0, 0		/* �������ƼĴ��� */ 
	orr	r1, r1, #0xc0000000			/* ����Ϊ��asynchronous bus mode�� */
	mcr	p15, 0, r1, c1, c0, 0		/* д����ƼĴ��� */

/* ����MPLLCON = S3C2440_MPLL_400MHZ; P256 */
	ldr r0, =0x4c000004
	ldr r1, =S3C2440_MPLL_400MHZ
	str r1, [r0]

/*�Ż��ٶȣ� ����ICACHE */
	mrc p15, 0, r0, c1, c0, 0	@ read control reg
	orr r0, r0, #(1<<12)
	mcr	p15, 0, r0, c1, c0, 0   @ write it back


/* 3. ��ʼ��SDRAM��������SDRAM�Ĵ��� д��sdram_config�е�ֵ*/
	ldr r0, =MEM_CTL_BASE	//��SDRAM�Ĵ�������ַд��r0��
	adr r1, sdram_config    //��sdram_config�ĵ�ǰ��ַд��r1;
	add r3, r0, #(13*4)     //r3=r0+13*4,��ΪSDRAM�Ĵ�����β��ַ��
1:
	ldr r2, [r1], #4        //��r1�Ĵ�����ֵ����r2������r1�ĵ�ַ+4;
	str r2, [r0], #4     	//��r2��ֵд��r0������r0�ĵ�ַ+4;
	cmp r0, r3 				//�Ƚ�r0��r3���ж��Ƿ����õ������һ���Ĵ�����
	bne 1b					//����ȼ�û�������꣬����ǰ��(b)��1����

/* 4. �ض�λ : ��bootloader�����Ĵ����flash���Ƶ��������ӵ�ַȥ */
	ldr sp, =0x34000000     //�ڵ���C����ǰ����Ҫ������ջ����SPָ��һ����ַ��
 
	bl nand_init            //��ʼ��nand flash��

	mov r0, #0              //����copy_code_to_sdram�������������1��r0=0��
	ldr r1, =_start         //����2��r1=_start��
	ldr r2, =__bss_start    //r2=__bss_start
	sub r2, r2, r1          //����3��r2=r2-r1 ����ȥ_bss�εĲ��֣�
	
	bl copy_code_to_sdram   //ִ�и��ƴ��뵽SDRAM�ĺ�����
	bl clear_bss            //ִ������_bss�κ�����
	 
/* 5. ִ��main */
	ldr lr, =halt
	ldr pc, =main
halt:
	b halt

sdram_config:            //��Ҫ���õ�ֵ���������P56;
	.long 0x22011110	 //BWSCON
	.long 0x00000700	 //BANKCON0
	.long 0x00000700	 //BANKCON1
	.long 0x00000700	 //BANKCON2
	.long 0x00000700	 //BANKCON3  
	.long 0x00000700	 //BANKCON4
	.long 0x00000700	 //BANKCON5
	.long 0x00018005	 //BANKCON6
	.long 0x00018005	 //BANKCON7
	.long 0x008C04F4	 //REFRESH
	.long 0x000000B1	 //BANKSIZE
	.long 0x00000030	 //MRSRB6
	.long 0x00000030	 //MRSRB7
