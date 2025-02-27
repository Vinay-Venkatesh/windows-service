using NUnit.Framework;
using SuperService.Controllers;
using Microsoft.Extensions.Logging;
using Moq;

namespace SuperService.UnitTests
{
  public class TimeControllerTests
  {
    private TimeController controller;
    private static readonly System.DateTime now = new System.DateTime(2020, 01, 01);

    [SetUp]
    public void Setup()
    {
      // Mocking the ILogger for dependency Injection.
      var mockLogger = new Mock<ILogger<TimeController>>();
      controller = new TimeController(new MockClock(now), mockLogger.Object);
    }

    [Test]
    public void TheTimeIsNow()
    {
      var time = controller.Get();

      Assert.That(time, Is.EqualTo(now));
    }
  }
}