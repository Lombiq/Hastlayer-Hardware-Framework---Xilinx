#include "EchoServerTcpAcceptCallbackProvider.h"


namespace HastlayerOperatingSystem
{

static err_t EchoServerReceiveCallback(void *tcpArgument, struct tcp_pcb *controlBlock, struct pbuf *buffer, err_t errorResult)
{
	// Don't read the packet if we are not in ESTABLISHED state.
	if (!buffer)
	{
		tcp_close(controlBlock);
		tcp_recv(controlBlock, NULL);

		return ERR_OK;
	}

	tcp_recved(controlBlock, buffer->len);

	// Echo back the payload.
	if (buffer->len <= tcp_sndbuf(controlBlock))
	{
		tcp_write(controlBlock, buffer->payload, buffer->len, 1);
	}

	pbuf_free(buffer);

	return ERR_OK;
}

static err_t EchoServerAcceptCallback(void *tcpArgument, struct tcp_pcb *newControlBlock, err_t errorResult)
{
	tcp_recv(newControlBlock, EchoServerReceiveCallback);

	return ERR_OK;
}


tcp_accept_fn EchoServerTcpAcceptCallbackProvider::GetCallback()
{
	 return EchoServerAcceptCallback;
}

} /* namespace HastlayerOperatingSystem */
