/* example1_port_driver.c */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

write_exact(unsigned char *buf, int len)
{
  int i, wrote = 0;
  do {
    if ((i = write(1, buf+wrote, len-wrote)) <= 0)
      return (i);
    wrote += i;
  } while (wrote<len);
  return (len);
}
write_cmd(unsigned char *buf, int len)
{
  unsigned char li;
  li = (len >> 8) & 0xff;
  write_exact(&li, 1);
  li = len & 0xff;
  write_exact(&li, 1);
  return write_exact(buf, len);
}


/* port.c */
typedef unsigned char byte;
int main() {
  int fn, arg, res;
  unsigned char buf[100];
  int len;
  FILE* f;
  f = fopen("port.log", "w");
  fprintf(f, "port start!\n");
  
  while ((len = read(0, buf, 9000)) > 0) {
  	buf[len] = 0;
  	fprintf(f, "was read %d:%s;\n", len, buf+2);
    write_cmd("ko\n", 3);
 //   write_exact("ok\n", 2);
    break;
  }
}

