using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;

namespace BookSystem.Models
{
    public class BookSearchArg
    {
        /// <summary>
        /// 書籍編號
        /// </summary>
        public int BookId { get; set; }

        /// <summary>
        /// 書名
        /// </summary>
        [DisplayName("書名")]
        public string BookName { get; set; }

        /// <summary>
        /// 圖書類別代碼
        /// </summary>
        [DisplayName("圖書類別")]
        public string BookClassId { get; set; }

        /// <summary>
        /// 借閱人ID
        /// </summary>
        [DisplayName("借閱人")]
        public string KeeperId { get; set; }

        /// <summary>
        /// 借閱狀態代碼
        /// </summary>
        [DisplayName("借閱狀態")]
        public string BookStatusCode { get; set; }

    }
}