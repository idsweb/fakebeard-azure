using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace demowebapp1.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        public List<Blob> blobs;

        public void OnGet()
        {
            blobs = new List<Blob>();
            blobs.Add(new Blob(){ Name = "Blob 1"});
        }
    }

    class Blob{
        public string Name { get; set; }
    }
}
