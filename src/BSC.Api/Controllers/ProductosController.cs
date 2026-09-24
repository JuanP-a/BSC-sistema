using BSC.Business.Services;
using BSC.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BSC.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProductosController : ControllerBase
{
    private readonly ProductoService _productos;

    public ProductosController(ProductoService productos)
    {
        _productos = productos;
    }

    [HttpGet]
    [Authorize(Roles = "Administrativo,Administrador")]
    public async Task<IActionResult> Listar([FromQuery] bool soloActivos = true)
    {
        var productos = await _productos.ListarAsync(soloActivos);
        return Ok(productos);
    }

    [HttpGet("existencias")]
    [Authorize(Roles = "Administrativo,Administrador")]
    public async Task<IActionResult> Existencias()
    {
        var existencias = await _productos.ObtenerExistenciasAsync();
        return Ok(existencias);
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Administrativo,Administrador")]
    public async Task<IActionResult> Obtener(int id)
    {
        var producto = await _productos.ObtenerPorIdAsync(id);
        if (producto is null) return NotFound(new { error = "Producto no encontrado." });
        return Ok(producto);
    }

    [HttpPost]
    [Authorize(Roles = "Administrativo,Administrador")]
    public async Task<IActionResult> Crear([FromBody] Producto producto)
    {
        var result = await _productos.CrearAsync(producto);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return CreatedAtAction(nameof(Obtener), new { id = result.Value }, new { id = result.Value });
    }
}
