using System.Security.Claims;
using BSC.Business.Services;
using BSC.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BSC.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PedidosController : ControllerBase
{
    private readonly PedidoService _pedidos;

    public PedidosController(PedidoService pedidos)
    {
        _pedidos = pedidos;
    }

    [HttpGet]
    [Authorize(Roles = "Administrativo,Administrador")]
    public async Task<IActionResult> Listar()
    {
        var pedidos = await _pedidos.ListarAsync();
        return Ok(pedidos);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Obtener(int id)
    {
        var pedido = await _pedidos.ObtenerPorIdAsync(id);
        if (pedido is null) return NotFound(new { error = "Pedido no encontrado." });
        return Ok(pedido);
    }

    [HttpPost]
    [Authorize(Roles = "Vendedor")]
    public async Task<IActionResult> Crear([FromBody] CrearPedidoRequest request)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? User.FindFirst("sub")?.Value;

        if (!int.TryParse(userIdClaim, out var vendedorId))
            return Unauthorized(new { error = "Token invalido." });

        var result = await _pedidos.CrearAsync(vendedorId, request.ClienteNombre, request.Detalles);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return CreatedAtAction(nameof(Obtener), new { id = result.Value }, new { id = result.Value });
    }
}

public class CrearPedidoRequest
{
    public string ClienteNombre { get; set; } = string.Empty;
    public List<PedidoDetalleInput> Detalles { get; set; } = new();
}
