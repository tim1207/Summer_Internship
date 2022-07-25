using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace BookSystem.Models
{   
    // book
    public class Books
    {
        /// <summary>
        /// 書籍ID
        /// </summary>
        ///[MaxLength(5)]
        [DisplayName("圖書編號")]
        public int BookID { get; set; }


        /// <summary>
        /// 書名
        /// </summary> 
        [DisplayName("書名")]
        [MaxLength(200)]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookName { get; set; }

        /// <summary>
        /// 圖書類別ID
        /// </summary>
        [DisplayName("圖書類別ID")]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookClassID { get; set; }

        /// <summary>
        /// 圖書類別
        /// </summary>
        ///[MaxLength(5)]
        [DisplayName("圖書類別")]
        public string BookClassName { get; set; }

        /// <summary>
        /// 作者
        /// </summary>
        [DisplayName("作者")]
        [MaxLength(30)]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookAuthor { get; set; }

        /// <summary>
        /// 購買日期
        /// </summary>
        [DisplayName("購買日期")]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookBoughtDate { get; set; }

        /// <summary>
        /// 書本金額
        /// </summary>
        [DisplayName("書本金額")]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookAmount { get; set; }

        /// <summary>
        /// 出版社
        /// </summary>
        [DisplayName("出版社")]
        [MaxLength(20)]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookPublisher { get; set; }

        /// <summary>
        /// 內容簡介
        /// </summary>
        [DisplayName("內容簡介")]
        [MaxLength(1000)]
        [Required(ErrorMessage = "此欄位必填")]
        public string BookNote { get; set; }

        /// <summary>
        /// 借閱人
        /// </summary>
        [DisplayName("借閱人")]
        public string UserName { get; set; }

        /// <summary>
        /// 借閱人ID
        /// </summary>
        [DisplayName("借閱人ID")]
        public string KeeperId { get; set; }

        /// <summary>
        /// 借閱狀態
        /// </summary>
        /// BookStatu
        [DisplayName("借閱狀態")]
        public string BookStatus { get; set; }


        /// <summary>
        /// 借閱狀態ID
        /// </summary>
        [DisplayName("借閱狀態ID")]
        public string CodeID { get; set; }

    }
}