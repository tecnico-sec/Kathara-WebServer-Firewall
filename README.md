LETI 2020/21 | Segurança Informática em Redes e Sistemas

---

# Guia de Laboratório 5 - NetKit-WebServer-Firewall

## Objectivo

O objectivo do guia consiste em configurar um servidor de web Apache e
uma firewall simples (iptables).

## Exercício 1 -- Servidor web

O exercício consiste em configurar o servidor de web Apache. Este
servidor desenvolvido como um projecto de código aberto é desde 1996 o
mais usado a nível mundial.

Siga os passos indicados no "*official lab" Web Server* do Kathara, que
se encontra aqui:
[https://github.com/KatharaFramework/Kathara-Labs/tree/master/Application%20Level/WebServer][2].

## Exercício 2 -- Firewall

Considere a rede abaixo, disponível sob a forma de um laboratório kathara
no ficheiro guia5-iptables.tgz.

![Topologia de Rede][1]

1.  Execute esse laboratório.

2.  Execute um servidor *apache2* no servidor e aceda-lhe a partir do PC
    usando um *browser.*

3.  Se quiser bloquear o acesso do cliente ao servidor, quais são as
    *chain* e tabela do *iptables* que deve usar?

4.  Crie uma regra *iptables* para bloquear o acesso ao porto TCP/80 do
    servidor. Tente novamente aceder ao servidor e observe como já não é
    possível.

5.  Bloqueie as mensagens ICMP tipo 8 (Echo Request) do PC para o
    servidor. Observe como já não é possível fazer *ping* do PC para o
    servidor. Observe como ainda é possível fazer *ping* do servidor
    para o PC.

6.  Liste as regras da *firewall.* Apague a segunda.

## Referências

-   Kathara, [https://github.com/KatharaFramework/Kathara/wiki][3]

-   Oskar Andreasson, Iptables Tutorial, version 1.2.2,
    [http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html][4],
    2006

  [1]: media/topologia-de-rede.png
  [2]: https://github.com/KatharaFramework/Kathara-Labs/tree/master/Application%20Level/WebServer
  [3]: https://github.com/KatharaFramework/Kathara/wiki
  [4]: http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html
