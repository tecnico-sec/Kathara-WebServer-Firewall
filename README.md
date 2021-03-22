Instituto Superior Técnico, Universidade de Lisboa

**Segurança Informática em Redes e Sistemas**

# Guia de Laboratório - *Web Server and Firewall*

## Objetivo

O objetivo deste laboratório é configurar um servidor *web*, usando [*Apache*](https://httpd.apache.org/), e uma *firewall* simples, usando `iptables`.

## Introdução

O laboratório está estruturado em três partes sequenciais.
Em primeiro lugar, vamos configurar um servidor *web* *Apache* com o objetivo de servir uma página *web* simples.
Em segundo lugar, vamos adicionar um servidor de base de dados *SQL*, que será usado pelo servidor *web*.
Por fim, vamos configurar uma *firewall* para controlar o acesso à página *web*.

**Sugestão:** os comandos que fazem alterações e que queira tornar permanentes podem ser colocados no fim dos ficheiros de arranque (*startup*).
Isto permite reproduzir rapidamente o trabalho efetuado.  
Para testar alterações, pode criar pequenos *scripts* de *Python*/*Bash*, colocá-los na pasta `/shared` e chamá-los a partir dos ficheiros de *startup*.

## Exercício 1 -- Servidor *web*

O servidor *Apache* serve documentos, por exemplo, páginas *HTML*, para a *world wide web*.
Este servidor foi desenvolvido como um projeto de código aberto e é, desde 1996, o mais usado a nível mundial.

O exercício consiste em lançar o servidor *Apache* e configurá-lo, de modo a que, ao nível da aplicação, sejam colocadas algumas restrições sobre os documentos que estão acessíveis.

Vamos agora executar alguns passos para configurar o *Apache*.

1. Inicie o laboratório:

```bash
kathara lstart
```

2. Verifique que no `webserver` o serviço `apache2` está a correr.

```bash
/etc/init.d/apache2 status
```

A pasta `/etc/init.d` contém os serviços duma máquina *Linux* no modo `SysVInit`.
Atualmente será mais comum encontrar o comando `systemctl` do modo `systemd` em vez do `SysVInit`.
Ambos são alternativas para gerir a inicialização do sistema operativo e respetivos serviços.

3. No debian10, os URLs disponibilizados pelo *Apache*, mapeiam para ficheiros dentro da pasta `/var/www/html` por omissão.
Dentro do `webserver` execute o comando `curl` para tentar pedir o ficheiro `public/index.html`.

```bash
curl -v 'http://localhost/public/index.html'
curl -v 'http://localhost/notpublic/onlymine.jpg'
```

4. Após fazer este pedido, observe como o *Apache* guarda no ficheiro `/var/log/apache2/access.log` informação relativa ao pedido que foi feito.

```bash
tail -n 10 /var/log/apache2/access.log 
```

5. O *Apache* contém diferentes módulos que podem ser opcionalmente ativados para implementar funcionalidades. 
Um desses módulos é `cgi` (*common gateway interface*), que permite executar *scripts* quando um determinado documento é pedido.  
Para ativar o módulo:

```bash
a2enmod cgi
/etc/init.d/apache2 restart
```

Podemos verificar que o módulo foi ativado verificando que na pasta `/etc/apache2/mods-enabled` se encontra um ficheiro com o nome do módulo (no caso, `cgi`).

6. É possível executar *scripts* dentro da pasta `/usr/lib/cgi-bin/` como resposta a pedidos HTTP, por exemplo `public/exam_answers.py`:

```bash
curl -v 'http://127.1.2.3/cgi-bin/public/past_exam_answers.py'
```

7. Usando o `curl`, observe como, a partir do `pc1`, consegue obter as página web `http://<ip do webserver>/public/index.html` e `cgi-bin/public/past_exam_answers.py` como esperado.
Observar também que no ficheiro `access.log` foi registado o acesso pelo *IP* do `pc1`.  

Nota: ao tentar aceder a `exam_answers.py`, obterá um erro por não estar ligado ao serviço da base de dados. 
Este erro será corrigido no exercício 2.

9. Observe como, a partir do `pc1`, consegue obter `http://<ip do webserver>/notpublic/onlymine.jpg` e `cgi-bin/public/past_exam_answers.py`, o que não deveria acontecer.
Pelo menos conseguimos verificar que estes documentos foram acedidos indevidamente no `access.log`.
É necessário corrigir a configuração de modo a que os documentos não estejam acessíveis.

10. Vamos então desativar o acesso a esses documentos.
Para o fazer, o *Apache* permite definir permissões por pasta, criando um ficheiro `.htaccess` na raiz da pasta na qual queremos definir permissões.
Coloque um ficheiro `.htaccess` com este conteúdo na pasta `notpublic` e reinicie o laboratório:

```bash
deny from all
```

11. Volte a executar os pedidos com o `curl` e confirme que a resposta do servidor é `403 Forbidden`.

----

## Exercício 2 -- Servidor de bases de dados

Agora que temos o servidor *Apache* configurado, vamos adicionar um novo servidor à nossa rede que terá um serviço *SQL* ([MariaDB](https://mariadb.org/)), à escuta de pedidos na porta `3306`.
Este serviço será usado pelo `webserver` na página `http://<ip do webserver>/cgi-bin/public/past_exam_answers.py`.

A máquina `sqlserver` já está pré-configurada com um servidor de *SQL*.
Agora é necessário ligá-la à rede de modo a que esteja acessível pelo servidor.
Depois, é preciso modificar a segunda linha do ficheiro `exam_answers.py` para ter o *IP* e porta de acesso ao `sqlserver`.

Siga os seguintes passos:

1. Observe a topologia de rede da figura, vamos modificá-la de modo a que o servidor *SQL* fique ligado também à *firewall*.

![Topologia de Rede][1]

2. Adicione uma regra ao ficheiro `webserver.startup` de modo a saber para onde encaminhar os pacotes que vão para o `pc1`.

3. Modifique o ficheiro `lab.conf` de modo a ligar a máquina `sqlserver` ao switch `B`.

4. Confirme que o seguinte comando mostra resultados:

```bash
curl 'http://<ip do webserver>/cgi-bin/public/past_exam_answers.py'
```

5. Confirme que o seguinte comando não mostra resultados:

```bash
curl 'http://<ip do webserver>/cgi-bin/notpublic/future_exam_answers.py'
```

Mas, se for executado localmente no `webserver`, já deve funcionar:
```bash
python /usr/lib/cgi-bin/notpublic/future_exam_answers.py
```

----

## Exercício 3 -- *Firewall*

Agora que temos a nossa aplicação *web* de perguntas de exames a correr no servidor, de forma correta, vamos observar o comportamento do ponto de vista de um utilizador.
Recorde a topologia de rede que utilizou no exercício 2 e vamos observar o comportamento a partir do `pc1`.

1. No `pc1`, verifique que consegue aceder aos exames passados e não aos futuros, tal como se podia observar no servidor:

```bash
curl 'http://<ip do webserver>/cgi-bin/public/past_exam_answers.py'
curl 'http://<ip do webserver>/cgi-bin/notpublic/future_exam_answers.py'
```

2. Infelizmente, ainda temos problemas na nossa configuração de rede.
Observe o que acontece se executar o seguinte comando no cliente:

```bash
nmap <ip do sqlserver>
```

3. A porta do *MariaDB* (`3306`) está acessível ao mundo exterior.
Isto tem dois problemas.
Em primeiro lugar é possível a um atacante tentar descobrir a nossa senha (especialmente dado que a senha é `password`):

```bash
# a partir do pc1:
mysql -u root -D sirs -e "SELECT * from exams;" -h 5.5.5.3 -ppassword
```

Em segundo lugar, mesmo sem saber a senha, é possível que o atacante "bombardeie" a porta com pedidos de tentativas de estabelecimento de ligação que consumam recursos no servidor e impeçam ligações legítimas de serem estabelecidas.

4. Vamos utilizar a *firewall* para criar regras que forcem a só expormos os serviços da rede `5.5.5.0/24` que queremos **explicitamente** expor para o mundo exterior. 
Para isso vamos utilizar o comando `iptables` (no debian10 temos de usar o comando `iptables-legacy`, porque atualmente o comando `iptables` não funciona corretamente).

5. Na máquina `firewall`, execute seguinte comando para listar as regras atuais da *firewall*:

```
iptables -L
```

Verá que existem 3 tipos de regras (INPUT, FORWARD, OUTPUT), e que não existem regras configuradas na *firewall* atualmente.

6. Caso queira apagar a *firewall*, pode apagar todas as regras existentes executando:

```
iptables -F
```

7. Vamos começar por adicionar uma regra simples que bloqueia todos os pacotes ICMP (*pings*) que tenham como destino a *firewall*:

```
iptables –A INPUT –p icmp –j DROP
```

Se o comando falhar, relembra-se que deve usar o comando `iptables-legacy` em vez de `iptables`.

8. Observe o resultado na `firewall` (`iptables -L`) e verifique o resultado de tentar "pingar" a `firewall` e o `webserver` a partir do `pc1` e de estabelecer uma ligação *TCP* (obter uma página alojada no `webserver`).

```bash
ping 5.5.5.1
ping 5.5.5.2
curl 'http://5.5.5.2/public/index.html'
```

9. Apague a regra de *input* que adicionou:

```bash
iptables –D INPUT –p icmp –j DROP
``` 

10. Repita os passos 7 a 9, trocando `INPUT` com `FORWARD` e `OUTPUT`, de modo a observar o que acontece em cada caso.
Certifique-se que entende o que faz cada regra.

11. Se quisermos, também podemos criar regras mais específicas, por exemplo, a seguinte regra bloqueia ligações *TCP* com destino à porta 23 de qualquer endereço na rede `42.42.0.0/16` provenientes da rede `192.168.2.0/24`.

```bash
iptables –A INPUT –p tcp –s 192.168.2.0/24 -d 42.42.0.0/16 –-dport 23 –j DROP
```

12. Vamos agora proteger a rede.
Comece por apagar todas as regras que criou na *firewall*:

```bash
iptables -F
```

13. Crie uma regra de *ip tables* para bloquear o acesso de qualquer pacote do mundo exterior ao `sqlserver`.

14. Crie uma regra para bloquear pacotes *ICMP* do `sqlserver` para o mundo exterior.

15. Crie, caso necessario, uma regra para bloquear o redireccionamento de pacotes do mundo exterior para o `sqlserver`.

16. Crie regras, para garantir que no servidor *web* a única porta onde é possível criar ligações é a `80` (onde se está a escutar o *HTTP*), mas que o redireccionamento de pacotes continua ativo.

Pode testar que noutras portas não é possível criar ligações pondo um serviço à espera de ligações numa porta.
Por exemplo, pode usar o comando `nc -l 1314` para colocar um processo à espera de ligações na porta indicada como argumento.

17. Liste as regras da *firewall*.

18. Observe que continua a fazer conseguir pedidos *HTTP* do `pc1` para o `webserver`, mas que não consegue ligar-se ao `sqlserver` a partir do `pc1`.

Os objetivos de isolamento na configuração de rede foram alcançados!

----

## Referências

- *Kathará*, [https://github.com/KatharaFramework/Kathara/wiki][3]

- Oskar Andreasson, Iptables Tutorial, version 1.2.2,
    [http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html][4],
    2006

  [1]: media/topologia-de-rede.png
  [2]: https://github.com/KatharaFramework/Kathara-Labs/tree/master/Application%20Level/WebServer
  [3]: https://github.com/KatharaFramework/Kathara/wiki
  [4]: http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html
