using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace SuperService.Controllers
{
  [ApiController]
  [Route("[controller]")]
  public class TimeController : ControllerBase
  {
    private IClock clock;
    private readonly ILogger<TimeController> logger;

    public TimeController(IClock clock, ILogger<TimeController> logger)
    {
      this.clock = clock;
      // Initialise the logger variable.
      this.logger = logger ?? throw new ArgumentNullException(nameof(logger), "Issue with the Logger!");
    }

    [HttpGet]
    public DateTime Get()
    {
      DateTime now = clock.GetNow();
      // Adding sample logs to get more info during runtime.
      logger.LogInformation("[INFO] - TimeController was called at {Time}", now);
      return now;
    }
  }
}
