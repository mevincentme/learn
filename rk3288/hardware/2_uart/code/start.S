	
.text
.global  _start
_start: 				

@����ջ
	ldr  sp,=0x80000000	@����ջ,2G DDR�����λ��

	bl relocate      @�ض�λ
	@bl clean_bss     @��BSS��

	@adr r0, _start @�����ڻ�ȡ��ǰ����ĵ�ַ,��Ϊ��������main,main�����ٴ�ӡ����"int main(int addr)"
	@ldr  pc, =main @���û�ض�λ,����ֱ������main�����λ��(���ӽű���������ַ),�Ǹ�λ�õ�����δ֪,�϶�����
	bl main          @bl�����ת,������û���ض�λ,���ܵ�main��λ��

halt:
	b  halt 
	
relocate:
    adr r0, _start  @r0:���뵱ǰ�����ڵ�λ��,ʵ�������0x00000000,��Ӳ�����Ծ���
	ldr r1, =_start @r1:�������������ڵ�λ��,�����ӽű���ĵ�ַ,�û�����ڵ�λ��,����SDRAM
					@��������ͬ�����ض�λ,������Ҫ�ض�λ
	cmp r0, r1      @�Ƚ�r0��r1
	moveq pc,lr     @�����pc=lr,�����ص�����relocate��λ��;���������ִ�������ָ��
	
	ldr r2, =__bss_start @r2�������ӽű����__bss_start,������Ρ�ֻ�����ݶΡ����ݶεĽ���λ��
cpy:
	ldr r3, [r0], #4 @��r0��ַ�����ݷŵ�r3,r0�������ƶ�һ���ֽ�
	str r3, [r1], #4 @��r3�����ݷŵ�r1,r1�������ƶ�һ���ֽ�
	                 @����������˴���ӵ�ǰλ�ø��Ƶ����������ӵ�ַλ�õĲ���
    cmp r1, r2       @�ж��ǲ��Ǹ�������
    bne cpy          @����ȼ�������   
	
	mov pc, lr		     @pc=lr,�����ص�����relocate��λ��;
	
clean_bss:
	ldr r0, =__bss_start @r0=bss�ο�ʼλ��
	ldr r1, =__bss_end   @r1=bss�ν���λ��
	mov r2, #0           @r0=0,���0��
clean_loop:  
	str r2, [r0], #4     @��0д��bss�ο�ʼλ��,��r0�����һ���ֽ�
	cmp r0, r1           @�Ƚ�bss���ǲ�������
	bne clean_loop       @������������0
	
	mov pc, lr		     @pc=lr,�����ص�����clean_bss��λ��;	
    
	

