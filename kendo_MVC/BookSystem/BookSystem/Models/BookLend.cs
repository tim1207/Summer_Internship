using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;

namespace BookSystem.Models
{
    public class BookLend
    {/// <summary>
     /// 書籍ID
     /// </summary>
        [DisplayName("書籍ID")]
        public string BookID { get; set; }

        /// <summary>
        /// 借閱日期
        /// </summary>
        [DisplayName("借閱日期")]
        public string LendDate { get; set; }

        /// <summary>
        /// 借閱人編號
        /// </summary>
        [DisplayName("借閱人編號")]
        public string KeeperId { get; set; }

        /// <summary>
        /// 英文名字
        /// </summary>
        [DisplayName("英文名字")]
        public string UserEName { get; set; }

        /// <summary>
        /// 中文名字
        /// </summary>
        [DisplayName("中文名字")]
        public string UserCName { get; set; }
    }

}